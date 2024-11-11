from dataclasses import dataclass
from os.path import *
from os import environ, chdir, scandir, access, R_OK
from sys import platform
from time import time
from tempfile import gettempdir
from pathlib import Path
from datetime import datetime
from asyncio import gather
from git import Repo
from gcloud.aio.auth import Token
from gcloud.aio.storage import Storage



SSH_PRIVATE_KEY_FILES = ('id_rsa', 'id_ecdsa', 'id_ed25519')
GOOGLE_ADC_VAR = 'GOOGLE_APPLICATION_CREDENTIALS'
AWS_PROFILE_VAR = 'AWS_PROFILE'
AWS_REGION_VAR = 'AWS_REGION'
STORAGE_TIMEOUT = 15
GCS_SCOPES = ["https://www.googleapis.com/auth/cloud-platform.read-only"]
PWD = realpath(dirname(__file__))


@dataclass
class GitRepo:
    """ Data Class for a Git Repo """
    url: str
    branch: str
    ssh_private_key_file: str
    type: str = None
    local_path: str = None

    def configure(self, branch: str = None):
        """Configure default branch and private SSH key"""
        if 'github.com' in self.url:
            self.type = "github"
            self.branch = branch if branch else "main"
        if 'source.developers.google.com' in self.url:
            self.type = "google_csr"
            self.branch = branch if branch else "master"
        if self.url.startswith("ssh://"):
            self.set_ssh_variables()

    def pull(self, branch: str = None):
        """Pull existing Git repo, or clone if repo does not exist locally"""
        if branch:
            self.branch = branch
        temp_dir = gettempdir()
        to_path = self.url.split('/')[-1]
        self.local_path = join(temp_dir, to_path)

        now = time()
        if exists(self.local_path):
            print("starting git init:", self.local_path)
            repo = Repo(path=self.local_path)
            repo.git.reset('--hard', f'origin/{self.branch}')
            origin = repo.remotes.origin
            origin.pull()  # Perform git pull
            print("finished git pull in ", time() - now)
        else:
            chdir(temp_dir)
            _ = time()
            repo = Repo.clone_from(url=self.url, to_path=to_path, branch=self.branch)  # Perform git clone
            print("finished git clone in ", time() - now)

        chdir(PWD)  # Change back to base directory

    def set_ssh_variables(self) -> None:
        """Configure the Git SSH Variant & Private Key File by setting appropriate Environment Variables"""
        environ.update({'GIT_SSH_VARIANT': "ssh"})
        if not (environ.get('GIT_SSH_COMMAND')):
            # Scan SSH Key locations to find valid private key file
            using_windows = True if platform.startswith('win') else False
            home_dir = environ.get("USERPROFILE") if using_windows else environ.get('HOME')
            for private_key_file in SSH_PRIVATE_KEY_FILES:
                _ = f"{home_dir}/.ssh/{private_key_file}"
                if using_windows:
                    _ = _.replace("/", "\\")
                if exists(_) and isfile(_) and access(_, R_OK):
                    self.ssh_private_key_file = _
                    break
            environ.update({'GIT_SSH_COMMAND': f"ssh -i {self.ssh_private_key_file}"})
        print("Git using private ssh key:", self.ssh_private_key_file)
        print(environ)

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


@dataclass
class TFModule:
    """ Data Class for a Terraform Module """
    name: str
    root_path: str
    path: str = None
    backend: dict = None
    providers: dict = None
    authentication_file: str = None
    uses_workspaces: bool = None
    workspaces: list = None
    storage: Storage = None

    async def discover_backend(self) -> None:

        # Verify the path actually exists
        self.path = join(self.root_path, self.name)
        assert exists(self.path) and isdir(self.path), f"{self.path} is not a valid directory"
        self.backend = {'path': self.path, 'type': "unknown"}

        # Scan the directory for Terraform code files
        tf_files = [f for f in scandir(self.path) if f.name.lower().endswith(".tf")]

        # Examine each file for bucket information
        for tf_file in tf_files:
            with open(tf_file.path, 'r') as fp:
                in_terraform = False
                in_provider = False
                in_backend = False
                for line in fp:
                    if line.lstrip().startswith("#"):
                        in_comment = True
                    elif line.lstrip().startswith("/*"):
                        in_comment = True
                    elif line.lstrip().startswith("*/"):
                        in_comment = False
                    else:
                        in_comment = False
                    if in_comment:
                        continue
                    if 'terraform ' in line:
                        in_terraform = True
                    if in_terraform:
                        if 'provider ' in line and ' {' in line:
                            in_provider = True
                            provider = line.split("\"")[1]
                            print("Provider update:", provider, line)
                            self.providers.update({provider: {}})
                        if in_provider:
                            for k in ['credentials', 'project', 'region', 'zone']:
                                print("checking for", k, "in", line)
                                if f"{k} " in line:
                                    print("found", k, "in", line)
                                    v = line.split("\"")[1]
                                    self.providers[provider].update({k: v.lower()})
                                    print("Provider update:", k, v)
                                    print(self.providers)
                            if '}' in line:
                                in_provider = False
                        if 'backend ' in line:
                            in_backend = True
                            backend_type = line.split("\"")[1]
                            self.backend.update({
                                'type': backend_type.lower()
                            })
                        if in_backend:
                            if self.backend['type'] in ['s3', 'gcs']:
                                for k in ['bucket', 'prefix', 'credentials']:
                                    if f"{k} " in line:
                                        v = line.split("\"")[1]
                                        self.backend.update({k: v.lower()})
                            if '}' in line:
                                in_backend = False
                        if '}' in line:
                            in_terraform = False
        if self.backend['type'] in ['s3', 'gcs']:
            self.backend.update({
                'prefix': self.backend.get('prefix', "")
            })
        else:
            self.backend.update({'type': "local", 'bucket': None})

    async def set_credentials(self, authentication_file: str = None):

        if not authentication_file and self.backend['type'] in ['s3', 'gcs']:
            # Try to auto-detect local authentication file
            match(self.backend['type']):
                case 'gcs':
                    if not (authentication_file := environ.get(GOOGLE_ADC_VAR)):
                        if home := environ.get('HOME'):
                            authentication_file = f"{home}/.config/gcloud/application_default_credentials.json"
                        if userprofile := environ.get("USERPROFILE"):
                            authentication_file = f"{userprofile}\\AppData\\Roaming\\gcloud\\application_default_credentials.json"
                            fp = open(authentication_file, 'r')
                case 's3':
                    if home := environ.get('HOME'):
                        credentials_file = f"{home}/.aws/credentials"
                case _:
                    pass

        if authentication_file:
            if self.backend['type'] == "gcs":
                self.backend.update({
                    'key_path': realpath(authentication_file),
                })
                token = Token(service_file=self.backend.get('key_path'), scopes=GCS_SCOPES)
                self.storage = Storage(token=token)

    async def find_workspaces(self) -> None:

        self.workspaces = []

        if self.backend['type'] == 'local':
            if exists("terraform.d"):
                self.uses_workspaces = True
                self.backend.update({
                    'location': "terraform.d/"
                })
            else:
                self.uses_workspaces = False
                self.backend.update({
                    'location': "."
                })
            self.workspaces = [TFWorkSpace("default", self.backend)]
            return
        if self.backend['type'] == 's3':
            self.backend.update({'protocol': "s3"})
        if self.backend['type'] == 'gcs':
            self.backend.update({'protocol': "gs"})
        if protocol := self.backend.get('protocol'):
            self.uses_workspaces = True
            self.backend.update({
                'location': f"{protocol}://{self.backend['bucket']}/{self.backend['prefix']}",
                #'key_path': realpath(authentication_file) if authentication_file else None,
            })

        # Scan input files to build list of possible workspaces
        input_files = [f for f in scandir(self.path) if f.name.lower().endswith(".tfvars")]
        for input_file in input_files:
            if input_file.name.lower() != 'defaults.auto.tfvars':
                workspace_name = input_file.name.split('.')[0]
                w = TFWorkSpace(workspace_name, self.backend)
                self.workspaces.append(w)
        if len(self.workspaces) > 0:
            self.uses_workspaces = True

    async def examine_workspaces(self) -> None:

        if self.backend['type'] == 'local':
            if self.uses_workspaces:
                pass
            else:
                _ = Path(self.backend['location'])
                #assert _.is_file(), f"'{self.backend['location']}' is not a valid file"
                file_stat = _.stat()
                workspace = self.workspaces[0]
                if not workspace.state_file:
                    workspace.state_file = {}
                workspace.state_file.update({
                    'size': int(file_stat.st_size),
                    'last_update': file_stat.st_mtime,
                })

        if self.backend['type'] == 's3':
            pass  # TODO
        if self.backend['type'] == 'gcs':
            """
            storage_client = storage.Client.from_service_account_json(self.backend.get('key_path'))
            blobs = storage_client.list_blobs(self.backend['bucket'], prefix=self.backend['prefix'])
            """
            #scopes = ["https://www.googleapis.com/auth/cloud-platform.read-only"]
            #token = Token(service_file=self.backend.get('key_path'), scopes=scopes)
            #storage = Storage(token=token)
            params = {'prefix': self.backend['prefix']}
            objects = []
            while True:
                print("Calling storage", self.backend['bucket'], params)
                _ = await self.storage.list_objects(self.backend['bucket'], params=params, timeout=STORAGE_TIMEOUT)
                objects.extend(_.get('items', []))
                if next_page_token := _.get('nextPageToken'):
                    params.update({'pageToken': next_page_token})
                else:
                    break
            await self.storage.close()
            self.storage = None
            for blob in objects:
                #print(b.name)
                #workspace_name = blob.name.split('/')[-1].replace('.tfstate', "")
                workspace_name = blob['name'].split('/')[-1].replace('.tfstate', "")
                #_updated = str(blob.updated)[0:19]
                #print(blob['name'], blob['size'], blob['updated'])
                _updated = str(blob['updated'])[0:19]
                _updated = _updated[:10] + " " + _updated[11:19]
                updated = int(datetime.timestamp(datetime.strptime(_updated, "%Y-%m-%d %H:%M:%S")))
                workspaces = [w for w in self.workspaces if w.name == workspace_name]
                tasks = [w.configure() for w in workspaces]
                await gather(*tasks)

                #if len(workspaces) == 1:
                #    workspace = workspaces[0]
                for w in workspaces:
                    w.state_file.update({
                        #'size': int(blob.size),
                        'size': int(blob['size']),
                        'last_update': updated,
                    })
                #print("Workspace:", workspace_name, blob.size, updated)
                #self.workspace_details.update({
                #    workspace_key: {
                #        'size': b.size,
                #        'updated': updated,
                #    }
                #})

        _ = [w.name for w in self.workspaces if not w.state_file]
        if len(_) > 0:
            print("Null state files:", _)
        self.workspaces = sorted(self.workspaces, key=lambda w: w.state_file.get('last_update') if w.state_file else 0, reverse=True)

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


@dataclass
class TFWorkSpace:
    """ Data C lass for a Terraform Workspace """
    name: str
    module_backend: dict
    input_file: dict = None
    state_file: dict = None

    async def configure(self):

        if self.name == 'default':
            input_file = 'terraform.tfvars'
        else:
            input_file = f"{self.name}.tfvars"
        module_path = self.module_backend.get('path')
        self.input_file = {
            'name': input_file,
            'path': f"{module_path}/{input_file}",
            'fullpath': None,
            'size': None,
            'last_update': None,
        }
        #print("Configured input file", self.input_file, "for workspace", self.name)

        # Get size & timestamp for input file
        _ = str(join(module_path, self.input_file['path']))
        if exists(_):
            file_stat = Path(_).stat()
            self.input_file.update({
                'fullpath': _,
                'size': file_stat.st_size,
                'last_update': int(file_stat.st_mtime),
            })

        # Get Metadata for State file
        if not self.state_file:
            self.state_file = {'name': f"{self.name}.tfstate", 'size': None, 'last_update': 0}
        if location := self.module_backend.get('location'):
            if self.module_backend.get('type') == 'local':
                #state_file_url = realpath(f"{location}/{self.state_file['name']}")
                state_file_url = join(module_path, self.state_file['name'])
                if exists(state_file_url) and isfile(state_file_url):
                    print("State File:", state_file_url)
                    file_stat = Path(str(state_file_url)).stat()
                    self.state_file.update({
                        'size': file_stat.st_size,
                        'last_update': int(file_stat.st_mtime),
                    })
            else:
                state_file_url = f"{location}/{self.state_file['name']}"
        #print("Setting state file:", self.name, state_file_url)
        # Set the URL for the state file
            self.state_file.update({'url': state_file_url})

    async def fetch_state_file(self, service_file) -> str:

        #if not self.state_file:
        #    self.state_file = {'name': f"{self.name}.tfstate"}

        if self.state_file.get('url'):
            #storage_client = storage.Client.from_service_account_json(key_path)
            #bucket = storage_client.bucket(bucket_name)
            #blob = bucket.get_blob(blob_name)
            scopes = ["https://www.googleapis.com/auth/cloud-platform.read-only"]
            token = Token(service_file=service_file, scopes=scopes)
            storage = Storage(token=token)
            blob = await storage.download(bucket="", object_name=self.state_file['url'], timeout=STORAGE_TIMEOUT)
            print(blob)
            #return {'size': blob.size, 'updated': blob.updated}

            #_ = get_file_details(self.state_file_location, authentication_key_file)
            _ = {}  # TODO
            self.state_file.update({
                'size': blob.get('size'),
                'last_update': blob['updated'],
            })
        return ""  # TODO

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


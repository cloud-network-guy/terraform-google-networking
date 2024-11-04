from os.path import *
from os import environ, chdir, scandir, access, R_OK
from sys import platform
from tempfile import gettempdir
from pathlib import Path
from datetime import datetime
from git import Repo
from google.cloud import storage


SSH_PRIVATE_KEY_FILES = ('id_rsa', 'id_ecdsa', 'id_ed25519')
GOOGLE_ADC_VAR = 'GOOGLE_APPLICATION_CREDENTIALS'
AWS_PROFILE_VAR = 'AWS_PROFILE'
AWS_REGION_VAR = 'AWS_REGION'
PWD = realpath(dirname(__file__))


class GitRepo:

    def __init__(self, url: str, branch: str = None, ssh_private_key_file: str = None):

        self.url = url
        self.type = None
        self.branch = branch if branch else "main"
        if 'github.com' in self.url:
            self.type = "github"
        if 'source.developers.google.com' in self.url:
            self.type = "google_csr"
            self.branch = branch if branch else "master"

        temp_dir = gettempdir()
        to_path = url.split('/')[-1]
        self.location = join(temp_dir, to_path)

        if exists(self.location):
            repo = Repo(path=self.location)
            origin = repo.remotes.origin
            origin.pull()  # Perform git pull
        else:
            chdir(temp_dir)
            repo = Repo.clone_from(url=url, to_path=to_path, branch=branch)  # Perform git clone

        chdir(PWD)  # Change back to base directory

        self.ssh_private_key_file = None
        if self.url.startswith("ssh://"):
            self.configure_ssh_parameters(ssh_private_key_file)

    def configure_ssh_parameters(self, ssh_private_key_file: str = None) -> None:

        if not (environ.get('GIT_SSH_VARIANT')):
            environ.update({'GIT_SSH_VARIANT': "ssh"})

        if not (environ.get('GIT_SSH_COMMAND')):
            # Scan SSH Key locations to find valid private key file
            using_windows = True if platform.startswith('win') else False
            home_dir = environ.get('HOME')
            if using_windows:
                home_dir = environ.get("USERPROFILE")
            if ssh_private_key_file:
                self.ssh_private_key_file = ssh_private_key_file
            else:
                for private_key_file in SSH_PRIVATE_KEY_FILES:
                    _ = f"{home_dir}/.ssh/{private_key_file}"
                    if using_windows:
                        _ = _.replace("/", "\\")
                    if exists(_) and isfile(_) and access(_, R_OK):
                        self.ssh_private_key_file = _
                        break
            environ.update({'GIT_SSH_COMMAND': f"ssh -i {self.ssh_private_key_file}"})

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})

"""

class TFBackend:

    def __init__(self, backend_type: str = 'local', bucket: str = None, prefix: str = None):

        self.type = backend_type.lower()
        self.url = '.'

        if self.type in ('gcs', 'gs'):
            self.url = f"gs://{bucket}"
        if self.type == 's3':
            self.url = f"s3://{bucket}"
        if prefix:
            self.url = f"{self.url}{prefix}"

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})

"""


class TFModule:

    def __init__(self, name: str, location: str):

        self.name = name
        self.path = location
        self.backend = {'type': None}
        self.providers = {}
        self.uses_workspaces = None
        self.workspaces = []

        # Verify the path actually exists
        assert exists(self.path) and isdir(self.path), f"{self.path} is not a valid directory"

        # Get Provider & Backend configuration
        self.get_config()
        if self.backend['type'] == 'local':
            if exists("terraform.d"):
                self.uses_workspaces = True
                self.backend.update({
                    'location': "terraform.d/"
                })
            else:
                self.uses_workspaces = False
                self.workspaces = [TFWorkSpace("default", self.path)]
                return
        protocol = None
        if self.backend['type'] == 's3':
            protocol = "s3"
        if self.backend['type'] == 'gcs':
            protocol = "gs"
        if protocol:
            self.uses_workspaces = True
            self.backend.update({
                'location': f"{protocol}://{self.backend['bucket']}/{self.backend['prefix']}",
                #'key_path': realpath(authentication_file) if authentication_file else None,
            })

        # Get Workspaces
        if self.uses_workspaces:
            self.get_workspaces()
        else:
            self.workspaces = []
        #self.get_backend_workspaces()

    def get_config(self) -> None:

        # Scan the directory for Terraform code files
        tf_files = [f for f in scandir(self.path) if f.name.lower().endswith(".tf")]

        # Examine each file for bucket information
        for tf_file in tf_files:
            #print(tf_file)
            with open(tf_file.path, 'r') as fp:
                print("opened:", tf_file.path)
                in_terraform = False
                in_provider = False
                in_backend = False
                for line in fp:
                    if line.lstrip().startswith("#"):
                        in_comment = True
                    elif line.lstrip().startswith("/*"):
                        #print("In comment", line)
                        in_comment = True
                    elif line.lstrip().startswith("*/"):
                        #print("leaving comment", line)
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
                            #line = next(fp)
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
                            #line = next(fp)
                        #line = next(fp)
                        if 'backend ' in line:
                            in_backend = True
                            backend_type = line.split("\"")[1]
                            self.backend['type'] = backend_type.lower()
                            #line = next(fp)
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
                            #break
                print("closed:", tf_file.path)
        if self.backend['type'] in ['s3', 'gcs']:
            self.backend.update({
                'prefix': self.backend.get('prefix', "")
            })
        else:
            self.backend.update({'type': "local", 'bucket': None})

    def get_workspaces(self) -> None:

        # Scan input files to build list of possible workspaces
        input_files = [f for f in scandir(self.path) if f.name.lower().endswith(".tfvars")]
        for input_file in input_files:
            if input_file.name.lower() != 'defaults.auto.tfvars':
                workspace_name = input_file.name.split('.')[0]
                w = TFWorkSpace(workspace_name, self.path, self.backend['location'])
                self.workspaces.append(w)

    def get_workspace_details(self, authentication_file: str = None) -> None:

        if not authentication_file and self.backend['type'] in ['s3', 'gcs']:
            match(self.backend['type']):
                case 'gcs':
                    if not (authentication_file := environ.get(GOOGLE_ADC_VAR)):
                        if home := environ.get('HOME'):
                            authentication_file = f"{home}/.config/gcloud/application_default_credentials.json"
                        if userprofile := environ.get("USERPROFILE"):
                            authentication_file = f"{userprofile}\\AppData\\Roaming\\gcloud\\application_default_credentials.json"
                            fp = open(authentication_file, 'r')
                            print(fp)
                case 's3':
                    if home := environ.get('HOME'):
                        credentials_file = f"{home}/.aws/credentials"
                case _:
                    pass

        if authentication_file:
            self.backend.update({
                'key_path': realpath(authentication_file)
            })

        if self.backend['type'] == 'local':
            if self.uses_workspaces:
                _ = Path(self.backend['location'])
                assert _.is_file(), f"'{self.backend['location']}' is not a valid file"
                file_stat = _.stat()
                workspace = self.workspaces[0]
                workspace.state_file.update({
                    'size': int(file_stat.st_size),
                    'last_update': file_stat.st_mtime,
                })
        if self.backend['type'] == 's3':
            pass  # TODO
        if self.backend['type'] == 'gcs':
            storage_client = storage.Client.from_service_account_json(self.backend.get('key_path'))
            blobs = storage_client.list_blobs(self.backend['bucket'], prefix=self.backend['prefix'])
            for blob in blobs:
                #print(b.name)
                workspace_name = blob.name.split('/')[-1].replace('.tfstate', "")
                _updated = str(blob.updated)[0:19]
                updated = int(datetime.timestamp(datetime.strptime(_updated, "%Y-%m-%d %H:%M:%S")))
                workspaces = [w for w in self.workspaces if w.name == workspace_name]
                if len(workspaces) == 1:
                    workspace = workspaces[0]
                    workspace.state_file.update({
                        'size': int(blob.size),
                        'last_update': updated,
                    })
                #print("Workspace:", workspace_name, blob.size, updated)
                #self.workspace_details.update({
                #    workspace_key: {
                #        'size': b.size,
                #        'updated': updated,
                #    }
                #})

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


class TFWorkSpace:

    def __init__(self, name: str, module_path: str, module_backend_location: str = None):

        self.name = name

        # Get Metadate for Input File
        self.input_file = {'name': 'terraform.tfvars' if self.name == 'default' else f"{self.name}.tfvars"}
        _ = join(module_path, self.input_file['name'])
        self.input_file = {'path': _, 'size': None, 'last_update': None}
        if exists(_) and isfile(_):
            file_stat = Path(_).stat()
            self.input_file.update({
                'size': file_stat.st_size,
                'last_update': int(file_stat.st_mtime),
            })
        else:
            self.input_file = None

        # Get Metadata for State file
        self.state_file = {'name': f"{self.name}.tfstate", 'size': None, 'last_update': None}
        if module_backend_location:
            state_file_url = f"{module_backend_location}/{self.state_file['name']}"
        else:
            state_file_url = join(module_path, self.state_file['name'])
            if exists(state_file_url) and isfile(state_file_url):
                print("State File:", state_file_url)
                file_stat = Path(state_file_url).stat()
                self.state_file.update({
                    'size': file_stat.st_size,
                    'last_update': int(file_stat.st_mtime),
                })

        self.state_file.update({'url': state_file_url})

    def get_state_file(self):

        if self.state_file.get('url'):
            #_ = get_file_details(self.state_file_location, authentication_key_file)
            _ = {}  # TODO
            self.state_file.update({
                'size': _.get('size'),
                'last_update': _.get('updated'),
            })

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


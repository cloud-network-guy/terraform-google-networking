#!/usr/bin/env python3

import platform
from os import environ, chdir, listdir, scandir, access, R_OK, system
from os.path import realpath, dirname, join, exists, isfile, isdir
from pathlib import Path
from tempfile import gettempdir
from datetime import datetime
import yaml
import google.auth
import google.auth.transport.requests
from google.cloud import storage
from git import Repo

SCOPES = ['https://www.googleapis.com/auth/cloud-platform']
SSH_PRIVATE_KEY_FILES = ('id_rsa', 'id_ecdsa', 'id_ed25519')
PWD = realpath(dirname(__file__))
ADC_VAR = 'GOOGLE_APPLICATION_CREDENTIALS'
VALID_ACTIONS = ('version', 'init', 'plan', 'apply', 'providers')
OPTIONS = {'debug': True}


class TFBackend:

    def __init__(self, backend_type: str = 'local', bucket: str = None, prefix: str = None):

        self.type = backend_type
        self.url = '.'

        if self.type == 'gcs':
            self.url = f"gs://{bucket}"
        if self.type == 's3':
            self.url = f"s3://{bucket}"
        if prefix:
            self.url = f"{self.url}{prefix}"

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


class TFModule:

    def __init__(self, name: str, location: str = None, backend: TFBackend = None):
        self.name = name
        self.location = location
        self.workspaces = []
        if self.location:
            try:
                chdir(self.location)
            except Exception as e:
                raise f"Could not chdir to '{self.location}'"
            _ = {f.split('.')[0]: f for f in listdir() if f.endswith(".tfvars") and f != 'defaults.auto.tfvars'}
            self.workspaces = list(_.keys())
            self.workspace_details = {w: {'size': None, 'updated': 0} for w in self.workspaces}
        self.backend_type = 'local'
        self.bucket_name = None
        self.bucket_prefix = None
        self.get_backend_info()
        if self.backend_type == 's3':
            self.backend_location = f"s3://{self.bucket_name}/{self.bucket_prefix}"
        if self.backend_type == 'gcs':
            self.backend_location = f"gs://{self.bucket_name}/{self.bucket_prefix}"

    def get_backend_info(self) -> None:

        bucket = None
        prefix = None

        tf_files = [f.name for f in scandir(self.location) if f.name.lower().endswith(".tf")]
        for tf_file in tf_files:
            #print(tf_file)
            with open(tf_file, 'r') as fp:
                for line in fp:
                    if 'terraform ' in line:
                        line = next(fp)
                        if 'backend ' in line:
                            self.backend_type = line.split("\"")[1].lower()
                            in_backend = True
                            while in_backend:
                                if self.backend_type in ['s3', 'gcs']:
                                    line = next(fp)
                                    if '}' in line:
                                        in_backend = False
                                    else:
                                        if 'bucket ' in line:
                                            bucket = line.split("\"")[1]
                                        if 'prefix ' in line:
                                            prefix = line.split("\"")[1]
                            break
                    else:
                        continue

        if bucket:
            self.bucket_name = bucket
            self.bucket_prefix = prefix

    def get_backend_workspaces(self, authentication_file: str) -> []:

        if self.backend_type == 's3':
            return {}
        elif self.backend_type == 'gcs':
            key_path = realpath(authentication_file)
            storage_client = storage.Client.from_service_account_json(key_path)
            blobs = storage_client.list_blobs(self.bucket_name, prefix=self.bucket_prefix)
            for b in blobs:
                workspace_key = b.name.split('/')[-1].replace('.tfstate', "")
                _updated = str(b.updated)[0:19]
                print(workspace_key, _updated, "---")
                updated = int(datetime.timestamp(datetime.strptime(_updated, "%Y-%m-%d %H:%M:%S")))
                self.workspace_details.update({
                    workspace_key: {
                        'size': b.size,
                        'updated': updated,
                    }
                })
        else:
            _ = Path(self.backend_location)
            assert _.is_file(), f"'{self.backend_location}' is not a valid file"
            file_stat = _.stat()
            return {'size': file_stat.st_size, 'updated': file_stat.st_mtime}

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


class TFWorkSpace:

    def __init__(self, name: str, module: str, backend_location: str = None):

        self.name = 'default' if name == 'terraform' else name
        self.module = module
        self.input_file = 'terraform.tfvars' if name == 'default' else f"{name}.tfvars"
        self.state_file_location = f"{self.name}.tfstate"
        self.state_file_size = None
        self.state_file_last_update = None
        if backend_location:
            self.state_file_location = f"{backend_location}/{self.state_file_location}"

    def examine_state_file(self, authentication_key_file: str):

        if self.state_file_location:
            #_ = get_file_details(self.state_file_location, authentication_key_file)
            _ = {}
            self.state_file_size = _.get('size')
            self.state_file_last_update = _.get('updated')

    def __repr__(self):
        return str({k: v for k, v in vars(self).items() if v})

    def __str__(self):
        return str({k: v for k, v in vars(self).items() if v})


def get_gcp_access_token(key_file: str = None) -> str:

    if key_file:
        key_file = join(PWD, key_file)  # Convert relative to full path
        credentials = google.oauth2.service_account.Credentials.from_service_account_file(key_file, scopes=SCOPES)
    else:
        credentials, project_id = google.auth.default(scopes=SCOPES, quota_project_id=None)
    _ = google.auth.transport.requests.Request()
    credentials.refresh(_)
    return credentials.token


def configure_git_ssh(private_key_file: str = None):

    if not (git_ssh_variant := environ.get('GIT_SSH_VARIANT')):
        git_ssh_variant = "ssh"
        environ.update({'GIT_SSH_VARIANT': git_ssh_variant})

    if not (git_ssh_command := environ.get('GIT_SSH_COMMAND')):
        # Scan SSH Key locations to find valid private key file
        my_os = platform.system().lower()
        home_dir = environ.get('HOME')
        if my_os.startswith('win'):
            home_dir = environ.get("USERPROFILE")
        if not private_key_file:
            for private_key_file in SSH_PRIVATE_KEY_FILES:
                _ = f"{home_dir}/.ssh/{private_key_file}"
                if my_os.startswith('win'):
                    _ = _.replace("/", "\\")
                if exists(_) and isfile(_) and access(_, R_OK):
                    private_key_file = _
                    break
        environ.update({'GIT_SSH_COMMAND': f"ssh -i {private_key_file}"})


def check_file(file_name: str) -> Path:
    """
    Verify a file exists
    """
    _ = Path(join(PWD, str(file_name)))
    assert _.is_file() and _.stat().st_size > 0, f"File '{file_name}' does not exist or is empty!"
    return _


def check_directory(directory: str) -> bool:
    """
    Verify a directory exists
    """
    assert exists(directory), f"Directory '{directory}' does not exist"
    assert isdir(directory), f"Directory '{directory}' is not a directory"
    return True


def get_settings(input_file: str = "settings.yaml") -> dict:
    """
    Get settings
    """
    _ = check_file(input_file)
    with open(_, mode="rb") as fp:
        _ = yaml.load(fp, Loader=yaml.FullLoader)
        return _


def get_directories(environment: dict, directory: str = None) -> dict:
    """
    Get information for all directories
    """
    if url := environment.get('git_url'):
        # If Git repo URL used, verify it exists, then find
        temp_dir = gettempdir()
        check_directory(temp_dir)
        to_path = url.split('/')[-1]
        repo_dir = join(temp_dir, to_path)
    else:
        # Repo is already cloned as local directory
        repo_dir = environment.get('base_dir')
        check_directory(repo_dir)

    # Use specific sub-directory, if configured
    sub_dir = environment.get('sub_dir')
    root_dir = join(repo_dir, sub_dir) if sub_dir else repo_dir

    # Use specific directory within the root, if specified
    target_dir = join(root_dir, directory) if directory else root_dir
    #check_directory(target_dir)

    return {
        'repo': Path(repo_dir),
        'root': Path(root_dir),
        'target': Path(target_dir),
    }


def get_modules() -> list[TFModule]:

    settings = get_settings()
    _ = get_directories(settings)
    root_dir = str(_.get('root'))
    sub_directories = get_sub_directories(root_dir)
    if valid_modules := settings.get('modules'):
        modules = [TFModule(sub_dir, join(root_dir, sub_dir)) for sub_dir in sub_directories if sub_dir in valid_modules]
    else:
        modules = [TFModule(sub_dir, join(root_dir, sub_dir)) for sub_dir in sub_directories]
    return modules


def get_sub_directories(base_dir: str) -> dict:

    sub_directories = {}
    for subdir in [_.name for _ in scandir(base_dir) if _.is_dir()]:
        _subdir = join(base_dir, subdir)
        tf_files = [f.name for f in scandir(_subdir) if f.name.lower().endswith(".tf")]
        if len(tf_files) > 0:
            sub_directories.update({subdir: tf_files})
    return sub_directories


def get_file_details(location: str, authentication_key: str) -> dict:

    if location.startswith("s3://"):
        return {}
    elif location.startswith("gs://"):
        key_path = realpath(authentication_key)
        bucket_name = location.replace('gs://', "").split('/')[0]
        blob_name = location.replace(f"gs://{bucket_name}/", "")
        storage_client = storage.Client.from_service_account_json(key_path)
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.get_blob(blob_name)
        print(blob)
        return {'size': blob.size, 'updated': blob.updated}
    else:
        _ = Path(location)
        assert _.is_file(), f"'{location}' is not a valid file"
        file_stat = _.stat()
        return {'size': file_stat.st_size, 'updated': file_stat.st_mtime}


def get_workspaces(module_dir) -> dict:

    module_dir = Path(module_dir)
    try:
        chdir(module_dir)
    except Exception as e:
        raise f"Could not chdir to module '{module_dir}'"
    _ = {f.split('.')[0]: f for f in listdir() if f.endswith(".tfvars") and f != 'defaults.auto.tfvars'}

    return _


def git_repo(url: str, branch: str = None, debug: bool = False) -> None:

    temp_dir = gettempdir()
    to_path = url.split('/')[-1]
    repo_dir = join(temp_dir, to_path)

    if exists(repo_dir):
        if debug or OPTIONS.get('debug'):
            print("Doing git pull:", repo_dir)
        repo = Repo(path=repo_dir)
        origin = repo.remotes.origin
        origin.pull()  # Perform git pull
    else:
        chdir(temp_dir)
        if debug or OPTIONS.get('debug'):
            print("Cloning git repo in:", temp_dir)
        repo = Repo.clone_from(url=url, to_path=to_path, branch=branch)  # Perform git clone


def tf_init(directory: str = "./", options: str = None, debug: bool = False):

    options = f" {options}" if options else ""
    if debug or OPTIONS.get('debug'):
        print("Running terraform init in:", directory, "with options", options)
    chdir(directory)
    system(f"terraform init{options}")


def main(directory: str = ".", workspace: str = None, action: str = "plan", debug: bool = False) -> str:

    settings = get_settings()

    _ = get_directories(settings, directory)
    repo_dir = _.get('repo')
    root_dir = _.get('root')
    target_dir = _.get('target')
    branch = settings.get('branch', 'master')

    if url := settings.get('git_url'):
        git_repo(url=url, branch=branch)

    if not environ.get(ADC_VAR):
        if _google_adc_key := settings.get('google_adc_key'):
            google_adc_key = check_file(_google_adc_key)
            if debug or OPTIONS.get('debug'):
                print("Setting Google ADC Key:", google_adc_key)
            environ.update({ADC_VAR: str(google_adc_key)})

    # Initialize
    #root_dir = join(realpath(repo_dir), directory)
    if debug or OPTIONS.get('debug'):
        print("running init for ", target_dir)
    tf_init(target_dir)

    if workspace:
        workspaces = {'default': "terraform.tfvars"} if workspace == 'default' else {workspace: f"{workspace}.tfvars"}
    else:
        workspaces = get_workspaces(target_dir)

    if debug or OPTIONS.get('debug'):
        print("Root dir", root_dir, "Directory", directory)
    chdir(target_dir)
    #system(f"terraform -chdir='{directory}' plan")
    environ.update({'TF_WORKSPACE': workspace})
    tfvars_file = Path(join(target_dir, f"{workspace}.tfvars"))
    print(tfvars_file)
    system(f"terraform plan -var-file='{tfvars_file}'")
    return None

    _ = ""
    print('workspaces', workspaces)
    for workspace, var_file in workspaces.items():
        print("CHDIR to:", root_dir)
        chdir(root_dir)
        environ.update({'TF_WORKSPACE': workspace})
        #os.system(f"terraform -chdir='{directory}' plan -var-file='{var_file}'")
        system(f"terraform -chdir='{directory}' plan -var-file='{var_file}'")
        #os.system(f"terraform {action} -var-file=\"{var_file}\"")
        _ = _ + f"Using Terraform directory '{directory}' with workspace '{workspace}' and input file '{var_file}'..."
    return _


if __name__ == "__main__":

    import sys
    from pprint import pprint

    argv = sys.argv
    if len(argv) <= 2:
        sys.exit("Usage: " + argv[0] + " <module> <workspace>")

    action = argv[3] if len(argv) > 3 else None

    _ = main(directory=argv[1], workspace=argv[2], action=action)
    pprint(_)


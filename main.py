#!/usr/bin/env python3

import sys
import os
import platform
import pathlib
import tempfile
import yaml
import asyncio
import git
import google.auth
import google.auth.transport.requests

SCOPES = ['https://www.googleapis.com/auth/cloud-platform']
SSH_PRIVATE_KEY_FILES = ('id_rsa', 'id_ecdsa', 'id_ed25519')
PWD = os.path.realpath(os.path.dirname(__file__))


def get_gcp_access_token(key_file: str = None) -> str:

    if key_file:
        key_file = os.path.join(PWD, key_file)  # Convert relative to full path
        credentials = google.oauth2.service_account.Credentials.from_service_account_file(key_file, scopes=SCOPES)
    else:
        credentials, project_id = google.auth.default(scopes=SCOPES, quota_project_id=None)
    _ = google.auth.transport.requests.Request()
    credentials.refresh(_)
    return credentials.token


def configure_git_ssh(private_key_file: str = None):

    if not (git_ssh_variant := os.environ.get('GIT_SSH_VARIANT')):
        git_ssh_variant = "ssh"
        os.environ.update({'GIT_SSH_VARIANT': git_ssh_variant})

    if not (git_ssh_command := os.environ.get('GIT_SSH_COMMAND')):
        # Scan SSH Key locations to find valid private key file
        my_os = platform.system().lower()
        home_dir = os.environ.get('HOME')
        if my_os.startswith('win'):
            home_dir = os.environ.get("USERPROFILE")
        if not private_key_file:
            for private_key_file in SSH_PRIVATE_KEY_FILES:
                _ = f"{home_dir}/.ssh/{private_key_file}"
                if my_os.startswith('win'):
                    _ = _.replace("/", "\\")
                if os.path.exists(_) and os.path.isfile(_) and os.access(_, os.R_OK):
                    private_key_file = _
                    break
        os.environ.update({'GIT_SSH_COMMAND': f"ssh -i {private_key_file}"})


def check_file(file_name: str) -> pathlib.Path:

    _ = pathlib.Path(os.path.join(PWD, str(file_name)))
    assert _.is_file() and _.stat().st_size > 0, f"File '{file_name}' does not exist or is empty!"
    return _


def check_directory(directory: str) -> bool:

    assert os.path.exists(directory), f"Directory '{directory}' does not exist"
    assert os.path.isdir(directory), f"Directory '{directory}' is not a directory"
    return True


def get_environment(input_file: str = "environments.yaml", environment: str = None) -> dict:
    """
    Get information for all environments; return specific environment information, if requested
    """
    _ = check_file(input_file)
    with open(_, mode="rb") as fp:
        _ = yaml.load(fp, Loader=yaml.FullLoader)
        if environment:
            if not (e := _.get(environment)):
                raise f"Environment '{environment}' not found in '{input_file}'"
            return e
        else:
            return _


def get_directories(environment: dict, directory: str = None) -> dict:
    """
    Get information for all directories
    """
    if url := environment.get('git_url'):
        # If Git repo URL used, verify it exists, then find
        temp_dir = tempfile.gettempdir()
        check_directory(temp_dir)
        to_path = url.split('/')[-1]
        repo_dir = os.path.join(temp_dir, to_path)
    else:
        # Repo is already cloned as local directory
        repo_dir = environment.get('base_dir')
        check_directory(repo_dir)

    # Use specific sub-directory, if configured
    sub_dir = environment.get('sub_dir')
    root_dir = os.path.join(repo_dir, sub_dir) if sub_dir else repo_dir

    # Use specific directory within the root, if specified
    target_dir = os.path.join(root_dir, directory) if directory else root_dir
    #check_directory(target_dir)

    return {
        'repo': repo_dir,
        'root': root_dir,
        'target': target_dir,
    }


def get_sub_directories(base_dir: str) -> dict:

    sub_directories = {}
    for subdir in [_.name for _ in os.scandir(base_dir) if _.is_dir()]:
        tf_files = [f.name for f in os.scandir(subdir) if f.name.lower().endswith(".tf")]
        if len(tf_files) > 0:
            sub_directories.update({subdir: tf_files})
    return sub_directories


def get_state_url(module_dir: str = "./") -> str:

    url = None

    tf_files = [f.name for f in os.scandir(module_dir) if f.name.lower().endswith(".tf")]
    for tf_file in tf_files:
        print(tf_file)
        with open(tf_file, 'r') as fp:
            for line in fp:
                if 'terraform ' in line:
                    line = next(fp)
                    if 'backend ' in line:
                        backend_config_type = line.split("\"")[1].lower()
                        in_backend = True
                        while in_backend:
                            if not url:
                                if backend_config_type == 's3':
                                    url = "s3"
                                if backend_config_type == 'gcs':
                                    url = "gs"
                            if backend_config_type in ['s3', 'gcs']:
                                line = next(fp)
                                if '}' in line:
                                    in_backend = False
                                else:
                                    if 'bucket ' in line:
                                        bucket = line.split("\"")[1]
                                        url = f"{url}://{bucket}"
                                    if 'prefix ' in line:
                                        prefix = line.split("\"")[1]
                                        url = f"{url}/{prefix}"
                        break
                else:
                    continue

    return url if url else "terraform.tfstate"


def get_workspaces(module_dir: str = "./") -> dict:

    try:
        os.chdir(module_dir)
    except Exception as e:
        raise f"Could not chdir to module '{module_dir}'"
    _ = {f.split('.')[0]: f for f in os.listdir() if f.endswith(".tfvars") and f != 'defaults.auto.tfvars'}
    return _


def git_repo(url: str, branch: str = None) -> None:

    temp_dir = tempfile.gettempdir()
    to_path = url.split('/')[-1]
    repo_dir = os.path.join(temp_dir, to_path)

    if os.path.exists(repo_dir):
        print("Doing git pull:", repo_dir)
        repo = git.Repo(path=repo_dir)
        origin = repo.remotes.origin
        origin.pull()  # Perform git pull
    else:
        os.chdir(temp_dir)
        print("Cloning git repo in:", temp_dir)
        repo = git.Repo.clone_from(url=url, to_path=to_path, branch=branch)  # Perform git clone


def tf_init(module_dir: str = "./", options: str = None):

    os.chdir(module_dir)
    options = f" {options}" if options else ""
    os.system(f"terraform init{options}")


def main(environment: str, directory: str = ".", workspace: str = None, action: str = "plan") -> str:

    environments = get_environment()
    e: dict = environments.get(environment)

    _ = get_directories(e, directory)
    repo_dir = _.get('repo')
    root_dir = _.get('root')
    target_dir = _.get('target')
    branch = e.get('branch', 'master')

    if url := e.get('git_url'):
        git_repo(url=url, branch=branch)

    # Initialize
    tf_init(root_dir)

    if workspace:
        workspaces = {'default': "terraform.tfvars"} if workspace == 'default' else {workspace: f"{workspace}.tfvars"}
    else:
        workspaces = get_workspaces(target_dir)

    if _google_adc_key := e.get('google_adc_key'):
        google_adc_key = check_file(_google_adc_key)
        os.environ.update({'GOOGLE_APPLICATION_CREDENTIALS': str(google_adc_key)})

    print("Root dir", root_dir)
    os.chdir(root_dir)
    os.system(f"terraform -chdir='{directory}' plan")
    return None

    _ = ""
    print('workspaces', workspaces)
    for workspace, var_file in workspaces.items():
        print("CHDIR to:", root_dir)
        os.chdir(root_dir)
        os.environ.update({'TF_WORKSPACE': workspace})
        #os.system(f"terraform -chdir='{directory}' plan -var-file='{var_file}'")
        os.system(f"terraform -chdir='{directory}' plan -var-file='{var_file}'")
        #os.system(f"terraform {action} -var-file=\"{var_file}\"")
        _ = _ + f"Using Terraform directory '{directory}' with workspace '{workspace}' and input file '{var_file}'..."
    return _


if __name__ == "__main__":

    from pprint import pprint

    if len(sys.argv) <= 3:
        sys.exit("Usage: " + sys.argv[0] + " <environment> <module> <workspace>")

    e = sys.argv[1]
    d = sys.argv[2]
    w = sys.argv[3]
    if len(sys.argv) > 4:
        a = sys.argv[4]
    else:
        a = "plan"

    _ = main(environment=e, directory=d, workspace=w, action=a)
    pprint(_)


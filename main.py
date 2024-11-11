#!/usr/bin/env python3

import os
import yaml
import tomli
from time import time
#from asyncio import gather
import google.auth
import google.auth.transport.requests
from classes import *

SCOPES = ['https://www.googleapis.com/auth/cloud-platform']
PWD = realpath(dirname(__file__))
ADC_VAR = 'GOOGLE_APPLICATION_CREDENTIALS'
VALID_ACTIONS = ('version', 'init', 'plan', 'apply', 'providers')
OPTIONS = {'debug': True}
ENVIRONMENTS_FILE = "environments.yaml"
FIELDS_FILE = "fields.toml"


def get_gcp_access_token(key_file: str = None) -> str:

    if key_file:
        key_file = join(PWD, key_file)  # Convert relative to full path
        credentials = google.oauth2.service_account.Credentials.from_service_account_file(key_file, scopes=SCOPES)
    else:
        credentials, project_id = google.auth.default(scopes=SCOPES, quota_project_id=None)
    _ = google.auth.transport.requests.Request()
    credentials.refresh(_)
    return credentials.token

"""

def configure_git_ssh(private_key_file: str = None):

    if not (git_ssh_variant := environ.get('GIT_SSH_VARIANT')):
        git_ssh_variant = "ssh"
        environ.update({'GIT_SSH_VARIANT': git_ssh_variant})

    if not (git_ssh_command := environ.get('GIT_SSH_COMMAND')):
        # Scan SSH Key locations to find valid private key file
        using_windows = True if sys.platform.startswith('win') else False
        home_dir = environ.get('HOME')
        if using_windows:
            home_dir = environ.get("USERPROFILE")
        if not private_key_file:
            for private_key_file in SSH_PRIVATE_KEY_FILES:
                _ = f"{home_dir}/.ssh/{private_key_file}"
                if using_windows:
                    _ = _.replace("/", "\\")
                if exists(_) and isfile(_) and access(_, R_OK):
                    private_key_file = _
                    break
        environ.update({'GIT_SSH_COMMAND': f"ssh -i {private_key_file}"})

"""


def check_file(file_name: str) -> str:
    """
    Verify a file exists
    """
    _ = str(os.path.join(PWD, str(file_name)))
    assert os.path.exists(_), f"File '{_}' does not exist"
    assert os.path.isfile(_), f"File '{_}' is not a file"

    #_ = Path(join(PWD, str(file_name)))
    #assert _.is_file() and _.stat().st_size > 0, f"File '{file_name}' does not exist or is empty!"
    return _


def check_directory(directory: str) -> bool:
    """
    Verify a directory exists
    """
    assert os.path.exists(directory), f"Directory '{directory}' does not exist"
    assert os.path.isdir(directory), f"Directory '{directory}' is not a directory"
    return True


def get_settings(input_file: str = "settings.yaml") -> dict:
    """
    Get settings
    """
    _ = check_file(input_file)
    with open(_, mode="rb") as fp:
        _ = yaml.load(fp, Loader=yaml.FullLoader)
        return _


def get_environments(input_file: str = ENVIRONMENTS_FILE) -> dict:
    """
    Get environments
    """
    _ = check_file(input_file)
    fp = open(_, mode="rb")
    _ = yaml.load(fp, Loader=yaml.FullLoader)
    fp.close()
    return _


def get_fields(input_file: str = FIELDS_FILE) -> dict:

    _ = check_file(input_file)
    fp = open(_, mode="rb")
    _ = tomli.load(fp)
    fp.close()
    return _


"""
def get_directories(environment: dict, directory: str = None) -> dict:
    if url := environment.get('git_url'):
        # If Git repo URL used, verify it exists, then find
        temp_dir = tempfile.gettempdir()
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
"""


async def get_modules(environment: str, module: str = None) -> list[TFModule]:

    environments = get_environments()
    assert environment in environments, f"environment '{environment}' not found"

    root_dir = "."

    splits = {'start': time()}
    e = environments.get(environment)
    if url := e.get('git_url'):
        repo = GitRepo(url, branch=e.get('git_branch'), ssh_private_key_file=e.get('git_ssh_key'))
        #git_repo(url=url, branch=branch)
        repo.configure()
        repo.pull()
        sub_dir = str(e.get('sub_dir', ""))
        root_dir = join(repo.local_path, sub_dir) if sub_dir else repo.local_path
        print("Root directory:", root_dir)
    elif directory := e.get('directory'):
        root_dir = join(directory)
    splits['finish_git_init'] = time()

    sub_directories = get_sub_directories(root_dir)
    print([sub_dir for sub_dir in sub_directories])
    splits['scan_sub_dirs'] = time()

    """
    if valid_modules := e.get('modules'):
        modules = [TFModule(sub_dir, str(join(root_dir, sub_dir))) for sub_dir in sub_directories.keys() if sub_dir in valid_modules]
    else:
        modules = [TFModule(sub_dir, str(join(root_dir, sub_dir))) for sub_dir in sub_directories.keys()]
    """
    modules = [TFModule(sub_dir, str(join(root_dir, sub_dir))) for sub_dir in sub_directories.keys()]
    #modules = await gather(*tasks)
    if module:
        modules = [m for m in modules if m.name == module]
    if valid_modules := e.get('modules'):
        modules = [m for m in modules if m.name in valid_modules]
    splits['module_init'] = time()


    #modules = [m.get_config() for m in modules]
    tasks = [m.discover_backend() for m in modules]
    await gather(*tasks)
    splits['discover_backend'] = time()
    #print(modules)
    _ = time()
    tasks = [m.set_credentials(e.get('google_adc_key')) for m in modules]
    await gather(*tasks)
    splits['set_authentication'] = time()

    #modules = [m.find_workspaces() for m in modules]
    tasks = [m.find_workspaces() for m in modules]
    await gather(*tasks)
    splits['find_workspaces'] = time()


    #[module.get_workspace_details(e.get('google_adc_key')) for module in modules if module.uses_workspaces]
    #tasks = []
    #for module in modules:
    #    if module.uses_workspaces:
    #        tasks.append(create_task(module.get_workspace_details(e.get('google_adc_key'))))
    #tasks = [module.get_workspace_details(e.get('google_adc_key')) for module in modules if module.uses_workspaces]
    tasks = [m.examine_workspaces() for m in modules]
    await gather(*tasks)
    #_ = [module.get_backend_workspaces() for module in modules]
    splits['examine_workspaces'] = time()

    modules = sorted(modules, key=lambda m: len(m.workspaces), reverse=True)

    durations = {}
    last_split = splits['start']
    for key, timestamp in splits.items():
        if key != 'start':
            duration = round((splits[key] - last_split), 3)
            durations[key] = f"{duration:.3f}"
            last_split = timestamp
    durations['total'] = f"{round(last_split - splits['start'], 3):.3f}"
    print("Durations:", durations)

    return modules


async def get_workspaces(environment: str, module: str) -> list[TFWorkSpace]:

    #settings = get_settings()
    #module.get_workspace_details(settings.get('google_adc_key'))
    #return module.workspaces

    environments = get_environments()
    assert environment in environments, f"environment '{environment}' not found"

    root_dir = "."

    _ = time()
    e = environments.get(environment)
    print("Getting modules:", environment, module)
    modules = await get_modules(environment, module)
    print("Modules:", [m.name for m in modules])
    assert (len(modules) > 0), f"module '{module}' not found in environment '{environment}'"
    assert (len(modules) == 1), f"multiple modules found matching environment '{environment}' and module '{module}'"
    _ = modules[0]
    workspaces = _.workspaces

    _ = time()
    tasks = [w.configure() for w in workspaces]
    print("configure workspaces took", time() - _)
    await gather(*tasks)

    #for w in workspaces:
    #    print("Workspace:", w.name, w.input_file, w.state_file)
    print([w for w in workspaces if w.state_file.get('last_update') == None])
    print("Workspaces:", workspaces)

    workspaces = sorted(workspaces, key=lambda w: w.state_file.get('last_update'), reverse=True)

    return workspaces


def get_sub_directories(base_dir: str) -> dict:

    sub_directories = {}
    for subdir in [_.name for _ in scandir(base_dir) if _.is_dir()]:
        _subdir = join(base_dir, subdir)
        tf_files = [f.name for f in scandir(_subdir) if f.name.lower().endswith(".tf")]
        if len(tf_files) > 0:
            #print("Found Terraform sub-directories in base:", base_dir)
            sub_directories.update({subdir: tf_files})
    return sub_directories

"""

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

def get_workspaces(module_dir) -> list:

    module_dir = Path(module_dir)
    try:
        chdir(module_dir)
    except Exception as e:
        raise f"Could not chdir to module '{module_dir}'"
    workspaces = []
    for f in listdir():
        if f.endswith(".tfvars") and f != 'defaults.auto.tfvars':
            workspaces.append({
                'name': f.split('.')[0],
                'input_file': f,
            })

    return workspaces

def git_repo(url: str, branch: str = None, debug: bool = False) -> None:

    temp_dir = tempfile.gettempdir()
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

"""


def tf_init(directory: str = "./", options: str = None, debug: bool = False):

    options = f" {options}" if options else ""
    if debug or OPTIONS.get('debug'):
        print("Running terraform init in:", directory, "with options", options)
    chdir(directory)
    os.system(f"terraform init{options}")


def main(environment: str, module: str, workspace: str = None, action: str = "plan", debug: bool = False) -> str:

    environments = get_environments()
    assert environment in environments, f"environment '{environment}' not found"

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
    #os.system(f"terraform -chdir='{directory}' plan")
    environ.update({'TF_WORKSPACE': workspace})
    tfvars_file = Path(join(target_dir, f"{workspace}.tfvars"))
    print(tfvars_file)
    os.system(f"terraform plan -var-file='{tfvars_file}'")
    return None

    _ = ""
    print('workspaces', workspaces)
    for workspace in workspaces:
        print("CHDIR to:", root_dir)
        chdir(root_dir)
        environ.update({'TF_WORKSPACE': workspace['name']})
        var_file = workspace['input_file']
        #os.os.system(f"terraform -chdir='{directory}' plan -var-file='{var_file}'")
        os.system(f"terraform -chdir='{directory}' plan -var-file='{var_file}'")
        #os.os.system(f"terraform {action} -var-file=\"{var_file}\"")
        _ = _ + f"Using Terraform directory '{directory}' with workspace '{workspace}' and input file '{var_file}'..."
    return _


if __name__ == "__main__":

    from sys import argv, exit
    from pprint import pprint

    if len(argv) <= 3:
        exit("Usage: " + argv[0] + " <environment> <module> <workspace>")

    action = argv[4] if len(argv) > 4 else None

    _ = main(environment=argv[1], module=argv[2], workspace=argv[3], action=action)
    pprint(_)


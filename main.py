#!/usr/bin/env python3

from os import scandir, chdir, system, environ
from os.path import realpath, dirname, join, exists, isfile, isdir, splitext
from time import time
from asyncio import gather
import google.auth
import google.auth.transport.requests
from classes import TFModule, TFWorkSpace, GitRepo

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



def check_file(file_name: str) -> str:
    """
    Verify a file exists
    """
    _ = str(join(PWD, str(file_name)))
    assert exists(_), f"File '{_}' does not exist"
    assert isfile(_), f"File '{_}' is not a file"

    #_ = Path(join(PWD, str(file_name)))
    #assert _.is_file() and _.stat().st_size > 0, f"File '{file_name}' does not exist or is empty!"
    return _


def check_directory(directory: str) -> bool:
    """
    Verify a directory exists
    """
    assert exists(directory), f"Directory '{directory}' does not exist"
    assert isdir(directory), f"Directory '{directory}' is not a directory"
    return True

def get_config(input_file: str) -> dict:

    import tomli
    import yaml

    if _ := check_file(input_file):
        file_format = splitext(input_file)[-1].lower()
        with open(_, mode="rb") as fp:
            if 'yaml' in file_format:
                _ = yaml.load(fp, Loader=yaml.FullLoader)
            if 'toml' in file_format:
                _ = tomli.load(fp)
            return _
    return {}

def get_settings(input_file: str = "environments.toml") -> dict:

    return get_config(input_file)


def get_environments(input_file: str = ENVIRONMENTS_FILE) -> dict:

    return get_config(input_file)


def get_fields(input_file: str = FIELDS_FILE) -> dict:

    return get_config(input_file)


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
    modules = [TFModule(module_name, str(root_dir)) for module_name in sub_directories.keys()]
    if module:
        modules = [m for m in modules if m.name == module]
    if valid_modules := e.get('modules'):
        modules = [m for m in modules if m.name in valid_modules]
    splits['module_init'] = time()

    tasks = [m.discover_backend() for m in modules]
    await gather(*tasks)
    splits['discover_backend'] = time()

    tasks = [m.set_credentials(e.get('google_adc_key')) for m in modules]
    await gather(*tasks)
    splits['set_authentication'] = time()

    tasks = [m.find_workspaces() for m in modules]
    await gather(*tasks)
    splits['find_workspaces'] = time()

    tasks = [m.examine_workspaces() for m in modules]
    await gather(*tasks)
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


def tf_init(directory: str = "./", options: str = None, debug: bool = False):

    options = f" {options}" if options else ""
    if debug or OPTIONS.get('debug'):
        print("Running terraform init in:", directory, "with options", options)
    chdir(directory)
    system(f"terraform init{options}")


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
    tfvars_file = join(target_dir, f"{workspace}.tfvars")
    print(tfvars_file)
    system(f"terraform plan -var-file='{tfvars_file}'")
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


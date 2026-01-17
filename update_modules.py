#!/usr/bin/env python3

from pathlib import Path
from tempfile import gettempdir
from traceback import format_exc
from shutil import rmtree
import yaml
import git

GIT_HOST = "github.com"
GIT_USER = "cloud-network-guy"
GIT_REPO = "terraform-google-networking"
GIT_BRANCH = "main"
GIT_URL = f"https://{GIT_HOST}/{GIT_USER}/{GIT_REPO}"
SETTINGS_FILE = "settings.yaml"
TF_FILE_EXTENSIONS = ('.tf', '.md')
ENCODING = 'utf-8'
NEWLINE = '\n'
TEMP_DIR = Path(gettempdir())
PWD = Path(__file__).parent


def sync_tf_files(source_dir: Path, target_dir: Path) -> bool:

    # Copy source files to destination directory
    if not target_dir.exists():
        target_dir.mkdir()
    for source_file in source_dir.iterdir():
        if not (source_file.suffix in TF_FILE_EXTENSIONS):
            continue
        source_contents = source_file.read_text()
        target_file = Path(target_dir.joinpath(source_file.name))
        if target_file.exists():
            try:
                target_contents = target_file.read_text()
                if source_contents == target_contents:
                    continue
            except FileNotFoundError:
                pass
        target_file.write_text(source_contents, encoding=ENCODING, newline=NEWLINE)

    return True


def main():

    temp_dir = TEMP_DIR.joinpath(GIT_REPO)

    successful_pull = False
    if temp_dir.exists():
        # Do Git Pull with a hard reset
        try:
            repo = git.Repo(path=temp_dir)
            repo.git.reset('--hard', f'origin/{GIT_BRANCH}')
            repo.remotes.origin.pull()
            successful_pull = True
        except git.InvalidGitRepositoryError:
            rmtree(temp_dir)
        except Exception as e:
            raise e

    if not successful_pull:
        repo = git.Repo.clone_from(url=GIT_URL, to_path=temp_dir, branch=GIT_BRANCH)  # Perform git clone

    # Sync Parent Modules
    settings_path = Path(__file__).parent.joinpath(SETTINGS_FILE)
    settings = yaml.safe_load(settings_path.read_text())
    parent_modules = settings.get('parent_modules', [])
    for module in parent_modules:
        source_dir = temp_dir.joinpath(module)
        target_dir = PWD.joinpath(module)
        _ = sync_tf_files(source_dir, target_dir)

    # Sync Child Modules
    if not (child_modules := settings.get('child_modules')):
        # Build a list if Child modules from the source's modules/ subdirectory
        child_modules = [module.name for module in temp_dir.joinpath(f"modules").iterdir() if module.is_dir()]
    for module_name in child_modules:
        source_dir = temp_dir.joinpath(f"modules/{module_name}")
        target_dir = PWD.joinpath(f"modules/{module_name}")
        _ = sync_tf_files(source_dir, target_dir)

    # Sync this script
    this_script = Path(__file__)
    _ = temp_dir.joinpath(this_script.name).read_text()
    this_script.write_text(_, encoding=ENCODING, newline=NEWLINE)

if __name__ == "__main__":

    try:
        main()

    except Exception as e:
        quit(format_exc())

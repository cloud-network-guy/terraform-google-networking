#!/usr/bin/env python3
from pathlib import Path
from tempfile import gettempdir
from traceback import format_exc
from shutil import rmtree
from git import Repo, InvalidGitRepositoryError
import yaml

GIT_HOST = "github.com"
GIT_USER = "cloud-network-guy"
GIT_REPO = "terraform-google-networking"
GIT_BRANCH = "main"
GIT_URL = f"https://{GIT_HOST}/{GIT_USER}/{GIT_REPO}"
SETTINGS_FILE = "settings.yaml"
FILE_EXTENSIONS = ('.tf', '.md')
ENCODING = 'utf-8'
NEWLINE = '\n'
TEMP_DIR = Path(gettempdir())
PWD = Path(__file__).parent


def sync_tf_files(source_dir: Path, target_dir: Path) -> bool:

    # Copy source files to destination directory
    if not source_dir.exists():
        raise NotADirectoryError("Source Module directory not found:", source_dir)
    if not target_dir.exists():
        target_dir.mkdir()
    for source_file in source_dir.iterdir():
        if not (source_file.suffix in FILE_EXTENSIONS):
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
            repo = Repo(path=temp_dir)
            repo.git.reset('--hard', f'origin/{GIT_BRANCH}')
            repo.remotes.origin.pull()
            successful_pull = True
        except InvalidGitRepositoryError:
            rmtree(temp_dir)  # Git repo is corrupted, so just delete it
        except Exception as e:
            raise e
        
    if not successful_pull:
        repo = Repo.clone_from(url=GIT_URL, to_path=temp_dir, branch=GIT_BRANCH)  # Perform git clone

    # Open Settings file to get list of parent modules to sync
    settings_file = Path(__file__).parent.joinpath(SETTINGS_FILE)
    with settings_file.open(mode="rb") as _:
        settings = yaml.load(_, Loader=yaml.FullLoader)
    parent_modules = settings.get('parent_modules', [])

    # Sync Parent Modules
    for module in parent_modules:
        source_dir = temp_dir.joinpath(module)
        target_dir = PWD.joinpath(module)
        _ = sync_tf_files(source_dir, target_dir)

    # Sync Child Modules
    for module in temp_dir.joinpath(f"modules").iterdir():
        if not module.is_dir():
            continue
        module_name = module.name
        source_dir = temp_dir.joinpath(f"modules/{module_name}")
        target_dir = PWD.joinpath(f"modules/{module_name}")
        _ = sync_tf_files(source_dir, target_dir)


if __name__ == "__main__":

    try:
        main()
    except Exception as e:
        quit(format_exc())




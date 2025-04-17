#!/usr/bin/env python3

from pathlib import Path
from tempfile import gettempdir
from os import scandir
from os.path import realpath, dirname
from shutil import copy, rmtree
from filecmp import cmp
from traceback import format_exc
import yaml
import git

GIT_HOST = "github.com"
GIT_USER = "cloud-network-guy"
GIT_REPO = "terraform-google-networking"
GIT_BRANCH = "main"
GIT_URL = f"https://{GIT_HOST}/{GIT_USER}/{GIT_REPO}"
SETTINGS_FILE = "settings.yaml"
TF_EXTENSIONS = ('.tf', '.md')
TEMP_DIR = gettempdir()
PWD = Path(realpath(dirname(__file__)))


def sync_tf_files(source_dir: Path, target_dir: Path) -> bool:

    # Copy source files to destination directory
    if not target_dir.exists():
        target_dir.mkdir()
    for f in scandir(source_dir):
        do_copy = False
        source_file = Path(f)
        if source_file.suffix in TF_EXTENSIONS:
            do_copy = True
            target_file = Path(target_dir.joinpath(f.name))
            if target_file.exists:
                # This is returning tue for nonexistant files for some reason
                try:
                    if cmp(source_file, target_file):
                        do_copy = False
                except:
                    do_copy = True
        if do_copy:
            copy(source_file, target_dir)

    return True


def main():

    temp_dir = Path(TEMP_DIR).joinpath(GIT_REPO)
  
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
        # Do Git Clone
        repo = git.Repo.clone_from(url=GIT_URL, to_path=temp_dir, branch=GIT_BRANCH)  # Perform git clone

    # Sync Parent Modules
    _ = Path(__file__).parent.joinpath(SETTINGS_FILE)
    fp = open(_, mode="rb")
    _ = yaml.load(fp, Loader=yaml.FullLoader)
    parent_modules = _.get('parent_modules', [])
    fp.close()
    for module in parent_modules:
        source_dir = temp_dir.joinpath(module)
        target_dir = PWD.joinpath(module)
        _ = sync_tf_files(source_dir, target_dir)

    # Sync Child Modules
    for module in [d.name for d in scandir(temp_dir.joinpath(f"modules")) if d.is_dir()]:
        source_dir = temp_dir.joinpath(f"modules/{module}")
        target_dir = PWD.joinpath(f"modules/{module}")
        _ = sync_tf_files(source_dir, target_dir)


if __name__ == "__main__":

    try:
        main()
    except Exception as e:
        quit(format_exc())




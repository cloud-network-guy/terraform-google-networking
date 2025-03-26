#!/usr/bin/env python3

from pathlib import Path
from os import chdir, system


PWD = Path(__file__).parent
modules = [module for module in list(PWD.iterdir()) if module.is_dir()]
modules.extend([module for module in list(PWD.joinpath('modules').iterdir()) if module.is_dir()])

for module in modules:
    files = list(module.iterdir())
    tf_files = [_ for _ in files if _.suffix.lower() == ".tf"]
    if len(tf_files) > 0:
        chdir(str(module))
        system("terraform-docs markdown --output-file README.md .")

#!/usr/bin/env python3

from pathlib import Path
from os import chdir, system


# Get the current directory
PWD = Path(__file__).parent

# Get all sub-directories (parent modules)
modules = [module for module in list(PWD.iterdir()) if module.is_dir()]

# Add child modules
modules.extend([module for module in list(PWD.joinpath('modules').iterdir()) if module.is_dir()])

for module in modules:

    # Get all files in the directory
    files = list(module.iterdir())

    # Check if directory has valid Terraform files, skip if it does not
    tf_files = [_ for _ in files if _.suffix.lower() == ".tf"]
    if len(tf_files) < 1:
        continue

    # Change to that directory and Run the Readme generation script
    chdir(str(module))
    system("terraform-docs markdown --output-file README.md .")

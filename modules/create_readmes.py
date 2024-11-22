#!/usr/bin/env python3

from os import scandir, chdir, system
from os.path import realpath, dirname


PWD = realpath(dirname(__file__))
MODULES = [module for module in scandir(PWD) if module.is_dir()]

for module in MODULES:
    tf_files = [f for f in scandir(module.path) if f.name.lower().endswith(".tf")]
    if len(tf_files) > 0:
        chdir(module.path)
        system("terraform-docs markdown --output-file README.md .")

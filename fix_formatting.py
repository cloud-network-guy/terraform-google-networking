#!/usr/bin/env python3

from pathlib import Path
from traceback import format_exc

FILE_EXTENSIONS = ('.tf', '.md')
PWD = Path(__file__).parent
ENCODING = 'utf-8'
NEWLINE = '\n'

def main():

    modules = PWD.joinpath('modules')

    for module in modules.iterdir():
        if not module.is_dir():
            continue
        module_dir = modules.joinpath(module.name)
        for file in module_dir.iterdir():
            if file.is_file() and file.suffix in FILE_EXTENSIONS:
                contents = file.read_text()
                if not contents == file.read_text(encoding=ENCODING, newline=NEWLINE):
                    file.write_text(contents, encoding=ENCODING, newline=NEWLINE)
                    print("Fixed formatting for:", file)


if __name__ == "__main__":

    try:
        main()
    except Exception as e:
        quit(format_exc())

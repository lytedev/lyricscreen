#!/usr/bin/env python3

import os, pypandoc

# Build our reStructuredText version of the readme
try:
    from pypandoc import convert
    read_md = lambda f: convert(f, 'rst')
except ImportError:
    print("error: pypandoc module not found, could not convert Markdown to RST")
    sys.exit(1)

f = open('readme.txt', 'w+')
f.write(read_md('readme.md'))
f.close()

os.system('./setup.py register')


#!/usr/bin/env python3

import pypandoc, os

output = pypandoc.convert('readme.md', 'rst')

f = open('readme.txt','w+')
f.write(output)
f.close()

os.system("./setup.py register")


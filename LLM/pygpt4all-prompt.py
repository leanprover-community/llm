#!/usr/bin/env python3
from pygpt4all import GPT4All_J

import sys
import os

# TODO Better argument passing. We'd like to specify temperature, etc.
modelPath = sys.argv[1]
antiprompt = sys.argv[2]
max_tokens = int(sys.argv[3]) if 3 < len(sys.argv) else None

# TODO Unfortunately this prints to stdout, and makes the actual output hard to retrieve.
# See https://github.com/nomic-ai/pygpt4all/issues/100
model = GPT4All_J(modelPath)

# See API reference at https://nomic-ai.github.io/pygpt4all/
for token in model.generate(sys.stdin.read(), antiprompt=antiprompt, n_predict=max_tokens):
    print(token, end='', flush=True, file=sys.stderr)

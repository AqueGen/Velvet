#!/usr/bin/env bash
cd "$(dirname "$0")/../lua" && ~/luaenv/bin/busted -o utfTerminal "$@"

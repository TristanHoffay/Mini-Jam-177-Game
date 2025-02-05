#!/bin/sh
echo -ne '\033c\033]0;Mini Jam 177 Cards\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Cards of Consequence.x86_64" "$@"

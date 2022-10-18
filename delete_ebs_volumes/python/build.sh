#!/bin/sh

set -e

PIP_EXE="$(which pip3 || which pip)"
MD5_EXE="$(which md5sum || which md5)"

"$PIP_EXE" install -r requirements.txt --upgrade -t ./build
cp ./*.py ./build/

{
  echo "# dependencies" ;
  "$PIP_EXE" freeze --path ./build -r requirements.txt ;
  echo "# source" ;
  find . -name '*.py' -maxdepth 1 -exec "$MD5_EXE" {} \;
} > build.log

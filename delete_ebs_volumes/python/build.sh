#!/bin/sh

set -e
pip install -r requirements.txt --upgrade -t ./build
cp *.py ./build/

echo "# dependencies" > build.log
pip freeze --path ./build -r requirements.txt >> build.log
echo "# source" >> build.log
ls *.py | xargs md5sum >> build.log

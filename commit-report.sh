#!/bin/bash

DIR=repo

export TZ=Asia/Singapore

set -ex

for file in *.pdf; do
    DATE=$(date -r $file -Is)
    if [ -f $DIR/$file ] && cmp -s $file $DIR/$file; then
        echo "No change in $file"
    else
        cp $file $DIR
        pushd $DIR
        git add $file
        git commit -m "Update $file to $DATE" --date="$DATE"
        popd
    fi
done

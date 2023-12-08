#!/bin/bash

DIR=repo

export TZ=Asia/Singapore

set -ex


for file in coursesNL courses_specialNL; do
    DATE=$(python3 clean-sched.py $file.html)
    if [ -f $DIR/$file.sha1 ] && cmp -s $file.sha1 $DIR/$file.sha1; then
        echo "No change in $file.html"
    else
        cp $file.{html,sha1} $DIR
        pushd $DIR
        git add $file.{html,sha1}
        git commit -m "Update $file.html to $DATE" --date="$DATE"
        popd
    fi
done

#!/bin/bash

export TZ=Asia/Singapore
DIR=repo

if [ ! -d $DIR ]; then
    echo "Directory $DIR does not exist."
    exit 1
fi

set -e
if [ -n "$GITHUB_ACTIONS" ]; then
    set -x

    wget --no-verbose https://www.comp.nus.edu.sg/cug/soc-sched/ -O soc-sched.html
    wget --no-verbose https://www.comp.nus.edu.sg/cug/specialterm -O specialterm.html
fi

for file in soc-sched specialterm; do
    if [ -f $file.html ]; then
        DATE=$(./clean-sched.py $file.html)
        mv $file.json ./$DIR
        sed -n '/<article/,/<\/article>/p' $file.html >./$DIR/$file.html
        pushd ./$DIR
        if [ -n "$(git status -s)" ]; then
            git config user.email "github-actions[bot]@users.noreply.github.com"
            git config user.name "github-actions[bot]"
            git add $file.{html,json}
            git commit -m "Update $file.html to $DATE" --date="$DATE"
        else
            echo "No changes to $file.html"
        fi
        popd
    else
        echo "File $file.html does not exist."
    fi
done

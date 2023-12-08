#!/bin/bash

DIR=repo

if ! $CI; then
    GITHUB_REPOSITORY=LuminousXLB/coursereg
fi

export TZ=Asia/Singapore

set -ex

gh repo clone $GITHUB_REPOSITORY $DIR

pushd $DIR
git config user.name "GitHub Actions"
git config user.email "$USER@$HOST"
popd

wget -q -i list.txt

# Checkout soc-sched branch

git -C $DIR checkout soc-sched

for file in coursesNL courses_specialNL; do
    DATE=$(grep -oP '(?<=Last Modified on: ).*(?=</div>)' $file.html)
    DATE=$(date -d "$DATE" -Is)

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

git -C $DIR push

# Checkout coursereg-report branch

git -C $DIR checkout coursereg-report

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

git -C $DIR push

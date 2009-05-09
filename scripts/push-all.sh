#!/bin/bash

home=`pwd`
projects=". "`cat project-list`

for project in ${projects}
do
    cd ${project}
    git push
    cd ${home}
done

#!/bin/bash

retval=""

function read_default {

    p_prompt=$1
    p_default=$2

    echo -n ${p_prompt}

    if [ -n "${p_default}" ]
    then
        echo -n " [${p_default}]"
    fi

    echo -n ": "

    read value

    if [ -z "${value}" ]
    then
        value=${p_default}
    fi

    retval=${value}

}

function pexec {
    echo "> $@"
    echo `$@`
}

read_default "Project short name"
name=${retval}

read_default "Project long name" ${name}
long_name=${retval}

read_default "Project version" "0.1-SNAPSHOT"
version=${retval}

echo ""
echo "Creating project:"
echo "Name:      ${name}"
echo "Long Name: ${long_name}"
echo "Version:   ${version}"
echo ""

read_default "Is that ok? (yes/no)" "no"
confirm=${retval}

if [ ${confirm} != "yes" ]
then
    echo "Aborting..."
    exit 1
fi

echo "Creating project..."

if [ -e ${name} ]
then
    if [ -d ${name} ]
    then
        echo "Directory ${name} already exists. That's ok..."
    else
        echo "File ${name} already exists and it's not a directory!"
        exit 1
    fi
else
    echo "Creating project directory..."
    pexec mkdir ${name}
fi

if [ -e ${name}/pom.xml ]
then
    echo "pom.xml file exists. Skipping the creation"
else
    echo "Creating pom.xml file from template"
    script="s/\[\[name\]\]/${name}/g
    s/\[\[long_name\]\]/${long_name}/g
    s/\[\[version\]\]/${version}/g"
    sed -e "${script}" pom-template.xml >> ${name}/pom.xml
fi

echo "Creating standard files..."

if [ ! -e ${name}/README ]
then
    echo "README"
    echo "Nothing here yet" >> ${name}/README
fi

if [ ! -e ${name}/TODO ]
then
    echo "TODO"
    touch ${name}/TODO
fi

if [ ! -e ${name}/ChangeLog ]
then
    echo "Changelog"
    touch ${name}/ChangeLog
fi

if [ ! -e ${name}/src ]
then
    echo "src"
    pexec mkdir --parents ${name}/src/main/java ${name}/src/test/java
fi

if [ ! -e ${name}/doc ]
then
    echo "doc"
    mkdir ${name}/doc
fi

echo "Addng to GIT repository"
#pexec svn add --depth empty ${name}
#pexec svn add ${name}/pom.xml ${name}/ChangeLog ${name}/README ${name}/doc ${name}/src ${name}/TODO

echo "Setting .gitignore"
#pexec svn propset svn:ignore -F svnignore-template ${name}
cp gitignore-template ${name}/.gitignore

echo ""
echo "Done"
echo "Now you must add this project to parent pom.xml"
read_default "Open it for you now? (y/n)" "y"

if [ ${retval} = "y" ]
then
    vim pom.xml
fi

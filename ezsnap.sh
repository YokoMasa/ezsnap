#!/bin/bash

SNAP_DIR=~/.ezsnap
SNAP_CATALOG_FILE=catalog.txt

# Create .ezsnap directory if it does not exist
if [ ! -d ${SNAP_DIR} ]; then
    mkdir ${SNAP_DIR}
    touch ${SNAP_DIR}/${SNAP_CATALOG_FILE}
fi

list() {
    echo -e "ID\tTimestamp\tFile path\tComment"
    IFS=","
    while read id realpath filename timestamp hashed comment; do
        echo -e "${id}\t${timestamp}\t${realpath}\t${comment}"
    done < ${SNAP_DIR}/${SNAP_CATALOG_FILE}
}

snap() {
    if [ ! -f ${2} ]; then
        echo "ERROR: Given argument ${2} is not a file."
        exit 1
    fi

    realpath=$(realpath ${2})
    filename=$(echo ${2} | sed -E -e "s/.*\///g")
    timestamp=$(date --iso-8601=seconds)
    hashed=$(echo ${realpath}${timestamp} | md5sum | sed -e "s/ //g" -e "s/-//g")
    comment=$(echo $* | sed -E -e "s/^snap +${2}//g")
    
    # Back up target file into the SNAP_DIR
    cp ${2} ${SNAP_DIR}/${hashed}
    if [ $? != "0" ]; then
        echo "Snap failed."
        exit 1
    fi

    # Create backup record
    get_largest_id
    new_id=$(expr $? + 1)
    echo "${new_id},${realpath},${filename},${timestamp},${hashed},${comment}" >> ${SNAP_DIR}/${SNAP_CATALOG_FILE}
    echo "Snap successful. ID: ${new_id}"
}

delete() {
    id=${2}

    # Get hash for the id
    hashed=$(grep -E -e "^${id}," ${SNAP_DIR}/${SNAP_CATALOG_FILE} | cut -d "," -f 5)
    if [ ! -z "${hashed}" ]; then
        rm -f ${SNAP_DIR}/${hashed}
        if [ "$?" != "0" ]; then
            echo "ERROR: Error deleting file. ID: ${id}"
            exit 1
        fi
    else
        echo "ERROR: ID: ${id} does not exist."
        exit 1
    fi

    # Delete record
    sed -i -E -e "/^${id},/d" ${SNAP_DIR}/${SNAP_CATALOG_FILE}
    echo "Delete successful. ID: ${id}"
}

restore() {
    id=${2}
    target_path=${3}

    if [ -z "${target_path}" ]; then
        echo "ERROR: You must specify target path."
        exit 1
    fi

    # Get hash for the id
    hashed=$(grep -E -e "^${id}," ${SNAP_DIR}/${SNAP_CATALOG_FILE} | cut -d "," -f 5)
    if [ ! -z "${hashed}" ]; then
        cp -f ${SNAP_DIR}/${hashed} ${target_path}
        if [ "$?" != "0" ]; then
            echo "ERROR: Error copying file. ID: ${id}"
            exit 1
        fi
    else
        echo "ERROR: ID: ${id} does not exist."
        exit 1
    fi

    echo "Restore successful. ID: ${id}"
}

get_largest_id() {
    line=$(tail -n 1 ${SNAP_DIR}/${SNAP_CATALOG_FILE})
    if [ -z "${line}" ]; then
        return 0
    fi
    return $(echo ${line} | grep -o -E -e "^[0-9]+")
}

case ${1} in
    "list") list;;
    "delete") delete $*;;
    "restore") restore $*;;
    "snap") snap $*;;
    *) echo "USAGE: ./ezsnap.sh { list | snap FILE | restore ID PATH | delete ID }";;
esac

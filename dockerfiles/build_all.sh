#!/bin/sh

set -e

if [ "$#" -ne 1 ]; then
    echo "USAGE: $0 [tag number]"
    exit 1
fi

WORK_PATH=`dirname $0`
TAG=$1

for file_path in ${WORK_PATH}/Dockerfile.*; do
    model_name_lc=`echo ${file_path##*.} | tr '[:upper:]' '[:lower:]'`
    echo "Building ${model_name_lc}..."
    sudo docker build -t tsotsoslab/smiler_${model_name_lc}:${TAG} -f $file_path $WORK_PATH/../
done

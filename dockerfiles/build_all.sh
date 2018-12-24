#!/bin/sh

set -e

WORK_PATH=`dirname $0`

for file_path in ${WORK_PATH}/Dockerfile.*; do
    model_name_lc=`echo ${file_path##*.} | tr '[:upper:]' '[:lower:]'`
    echo "Building ${model_name_lc}..."
    sudo docker build -t tsotsoslab/smiler_${model_name_lc} -f $file_path $WORK_PATH/../
done

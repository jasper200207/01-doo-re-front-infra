#!/bin/sh

### Set Variables
MAIN_PATH=$(pwd)
BUILD_PATH="docker/data/front"
PROJECT_NAME="01-doo-re-front"

### Check Arguments / $1: prod or dev
echo "Check Arguments"
if [ $# -ne 1 ]; then
    echo 'Check Arguments'
    exit -1
fi

### Delete old files
echo "Delete old files"
rm -r $BUILD_PATH/*

### Download layered jar From S3
echo "Download layered jar From S3"
aws s3 cp s3://doo-re-dev-bucket/doo-re-front-dev-deploy/ $BUILD_PATH --include=$PROJECT_NAME.tar.gz* --recursive

if [ -d $BUILD_PATH/application ]
then
    rm -r \
        $BUILD_PATH/dependencies \
        $BUILD_PATH/snapshot-dependencies \
        $BUILD_PATH/spring-boot-loader \
        $BUILD_PATH/application
fi

echo "Unzip layered jar"
cd $BUILD_PATH
cat $PROJECT_NAME.tar.gz* | tar zxvf -
rm $PROJECT_NAME.tar.gz*
cd $MAIN_PATH

### Docker Compose Up
echo "Docker Compose Up"
docker-compose up -d
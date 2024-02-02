#!/bin/sh

### Set Variables
MAIN_PATH=$(pwd)
BUILD_PATH="docker/data/front"

### Check Arguments / $1: commit hash / $2: prod or dev
echo "Check Arguments"
if [ $# -ne 2 ]; then
    echo 'Check Arguments'
    exit -1
fi

### Delete old files
echo "Delete old files"
rm -r $BUILD_PATH/*

### Download Build Files From S3
echo "Download Build Files From S"
aws s3 cp s3://doo-re-dev-bucket/doo-re-front-dev-deploy/ $BUILD_PATH --include=$1.tar.gz* --recursive

### Unzip Build Files
echo "Unzip Build Files"
cd $BUILD_PATH
cat $1.tar.gz* | tar zxvf -
rm $1.tar.gz*
cd $MAIN_PATH

### Docker Compose Down
echo "Docker Compose Down"
docker-compose down --rmi all

### Docker Build
echo "Docker Build"
docker build -t doo-re-front:$2 -f $BUILD_PATH/Dockerfile .

### Docker Compose Up
echo "Docker Compose Up"
docker-compose -p doo-re-front up -d
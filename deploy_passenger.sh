#!/usr/bin/env bash

set -e

# PATHS
BUNDLE=$1
APP_ROOT=$(pwd)
APP_DIR=$APP_ROOT/app
APP_USER=$(< ./appuser)
BUNDLE_DIR=$APP_DIR/bundle
BACKUP_DIR=$APP_DIR/bundle_backup

clear
echo "[ INSTALL CORE APP ]"
echo ""
echo "APP_DIR=$APP_DIR"
echo "BUNDLE_DIR=$BUNDLE_DIR"
echo "BACKUP_DIR=$BACKUP_DIR"
echo "BUNDLE=$BUNDLE"

sleep 2

echo ""
echo "---------------------------"
echo " PART 1. FILESYS AND BACKUP"
echo "---------------------------"
echo ""

# IF NO APPDIR EXISTS CREATE
if [ ! -d $APP_DIR ]
then
    echo "[APP_DIR] create APP_DIR, please wait..." && mkdir -p $APP_DIR && echo "... APP_DIR created at $APP_DIR" && echo "" && sleep 2
fi

# REMOVE BACKUP DIR IF EXISTS
if [ -d $BACKUP_DIR ]
then
    echo "[BACKUP_DIR] remove BACKUP_DIR before backup, please wait..." && rm -Rf $BACKUP_DIR && echo "... BACKUP_DIR removed" && echo "" && sleep 2
fi

# RENAME BUNDLE TO BACKUP IF EXISTS
if [ -d $APP_DIR/bundle ]
then
    echo "[BUNDLE_DIR] create backup, please wait..." && mv $APP_DIR/bundle $BACKUP_DIR && echo "... backup created" && echo "" && sleep 2
fi

echo ""
echo "---------------------------"
echo " PART 2. INSTALL APP"
echo "---------------------------"
echo ""

# EXTRACTION
echo "[COPY] copy archived bundle [$BUNDLE] to APP_DIR"
cp $APP_ROOT/$BUNDLE $APP_DIR
cd $APP_DIR
echo "... copied"
echo ""
sleep 2

echo "[EXTRACT] extract bundle, please wait..."
tar -xpf ./$BUNDLE
echo "... removed copied archive"
rm $APP_DIR/$BUNDLE
echo "... extraction complete"
echo ""
sleep 2

# INSTALL DEPS
SERVER_DIR=$BUNDLE_DIR/programs/server
cd $SERVER_DIR

echo "[LINKING] link main file"
ln -s ../../main.js main.js
ls -la | grep main.js
echo "... linking complete"
echo ""
sleep 2

if [ ! -d $SERVER_DIR/assets/app/uploads ]
then
    echo "[ASSETS] create asset folders, please wait..."
    mkdir -p $SERVER_DIR/assets/app/uploads/files
    mkdir -p $SERVER_DIR/assets/app/uploads/unitfiles
    chmod -R 755 $SERVER_DIR/assets
    echo "... asset folders created"
    echo ""
    sleep 2
fi

echo "[permissions] setting permissions recursively"
chown -R ${APP_USER} $APP_DIR
echo "done"
sleep 2

echo "[NPM] install npm packages"
npm --unsafe-perm install
echo "... installation complete"
echo ""

echo "[ALL COMPLETE"]

ROOT_URL="http://localhost:3000"
MONGO_URL="mongodb://root:password@localhost:127.0.0.1:27017/admin"
SETTINGS='{"curriculum":{"sync":{"username":"","password":"", "url":"localhost:12345"}}, "public":{"student":{"host":""}}}'

service mongod start #starting mongodb

ROOT_URL=${ROOT_URL} MONGO_URL=${MONGO_URL} METEOR_SETTINGS=${SETTINGS} passenger start --app-type node --startup-file main.js # starting project through passenger






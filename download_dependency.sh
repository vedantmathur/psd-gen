#!/bin/bash

git --version 2>&1 >/dev/null # improvement by tripleee
GIT_IS_AVAILABLE=$?
# ...
if [ $GIT_IS_AVAILABLE -ne 0 ]; then 
    echo "This script requires git to be installed"
    exit
fi

DIR="Gamma-Scripts"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Pulling latest ${DIR}..."
  git -C $DIR pull
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Cloning ${DIR}..."
  git clone https://github.com/poe-lab/$DIR
fi

DIR="SDK_neuralynx_v5.0.1"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Pulling latest ${DIR}..."
  git -C $DIR pull
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Cloning ${DIR}..."
  git clone https://github.com/poe-lab/$DIR
fi

DIR="SharedSubFunctions"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Pulling latest ${DIR}..."
  git -C $DIR pull
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Cloning ${DIR}..."
  git clone https://github.com/poe-lab/$DIR
fi

DIR="TimeStampGenerators"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Pulling latest ${DIR}..."
  git -C $DIR pull
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Cloning ${DIR}..."
  git clone https://github.com/poe-lab/$DIR
fi
#!/bin/sh

cd $HOME
git clone https://github.com/bpmct/c4d-packer $HOME/coder/
cd $HOME/coder && INITIAL_PASSWORD=coder12345 docker-compose up -d

#!/bin/sh

cd $HOME
git clone https://github.com/bpmct/c4d-packer $HOME/coder/
cd $HOME/coder && docker-compose up -d
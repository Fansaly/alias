#!/bin/bash

cmd=ifconfig

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  cmd="ip a"
fi

alias localip="command $cmd | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"

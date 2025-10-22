#!/bin/bash

FNM_PATH="/home/deploy/.fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
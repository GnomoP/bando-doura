#!/bin/bash

while [[ "$?" == 0 ]]; do
  clear
  bundle exec ruby main.rb "$@"
done
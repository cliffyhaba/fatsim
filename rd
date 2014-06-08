#!/bin/bash

rdoc  --exclude=doc --exclude=test --exclude=rd --exclude=Doxy* --exclude=Make* --main=filehandler.rb -t 'Simulate FAT' 

echo $?



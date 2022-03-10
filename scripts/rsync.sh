#!/bin/bash

rsync --progress -r -avP --numeric-ids --exclude='/dev' --exclude='/proc' --exclude='/sys'

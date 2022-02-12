#!/bin/bash

CADMIUMROOT=$(dirname $(realpath $0))

source $CADMIUMROOT/config
source $CADMIUMROOT/board/$TARGET/boardinfo
source $CADMIUMROOT/baseboard/$BASEBOARD/boardinfo

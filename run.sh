#!/usr/bin/env sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
coffee "$SCRIPTPATH/server/server.coffee"

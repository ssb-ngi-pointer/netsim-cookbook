# SPDX-FileCopyrightText: 2021 Alexander 'cblgh' Cobleigh
#
# SPDX-License-Identifier: Unlicense

#!/usr/bin/env bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
DIR="$1"
PORT="$2"
# the following env variables are always set from netsim:
#   ${CAPS}   the capability key / app key / shs key
#   ${HOPS}   a integer determining the hops setting for this ssb node
# if ssb-fixtures are provided, the following variables are also set:
#   ${LOG_OFFSET}  the location of the log.offset file to be used
#   ${SECRET}      the location of the secret file which should be copied to the new ssb-dir
echo "starting go-ssb from ${SCRIPTPATH}"

mkdir -p "${DIR}/log"

if [ -n "${LOG_OFFSET}" ]
then
    # log.offset does not exist already -> run fixtures conversion script
    if [ ! -f ${DIR}/flume/log.offset ]
    then
        echo "running with log.offset at ${LOG_OFFSET}; initiating conversion script"
        # run fixtures conversion script
        ${SCRIPTPATH}/ssb-offset-converter -if lfo ${LOG_OFFSET} "$DIR/log"
    else 
        echo "puppet was started previously, and a ${LOG_OFFSET}-based log.offset already exists"
    fi
fi

if [ -n "${SECRET}" ]
then
    echo "running with a secret at ${SECRET}"
    cp ${SECRET} "$DIR/"
    # set correct perms on secret
    chmod 600 "$DIR/secret"
fi

echo "using ports ${PORT} and $(($PORT+1))"
echo "using caps ${CAPS} and hops ${HOPS}"
echo "puppet lives in ${DIR}"
export LIBRARIAN_WRITEALL=0 
# note: exec is important. otherwise the process won't be killed when the netsim has finished running :)
#exec ${SCRIPTPATH}/go-sbot -lis :"$PORT" -wslis :"$(($PORT+1))" -repo "$DIR" -shscap "${CAPS}" -hops "${HOPS}"
exec ${SCRIPTPATH}/go-sbot \
  -lis :"$PORT" \
  -wslis "" \
  -debuglis ":$(($PORT+1))" \
  -repo "$DIR" \
  -shscap "${CAPS}" \
  -hops "$(( ${HOPS} - 1 ))" \
  -promisc 

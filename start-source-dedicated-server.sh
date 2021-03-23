#!/usr/bin/env bash

if [ "${GAME}" == "" ]
then
    echo "Please set the GAME property."
    exit 1
elif [ "${GAME}" == "terrortown" ]
then
    echo "detected Trouble in Terrorist Town"
    export GAME_DIR=${GMOD_SERVER_DIR}
    export GAME_ARG="garrysmod +gamemode terrortown"
elif [ "${GAME}" == "prophunt" ]
then
    echo "detected Prop Hunt"
    export GAME_DIR=${GMOD_SERVER_DIR}
    export GAME_ARG="garrysmod +gamemode prop_hunt"
elif [ "${GAME}" == "css" ]
then
    echo "detected Counter-Strike: Source"
    export GAME_DIR=${CSS_SERVER_DIR}
    export GAME_ARG="cstrike"
elif [ "${GAME}" == "tf2" ]
then
    echo "detected Team Fortress 2"
    export GAME_DIR=${TF2_SERVER_DIR}
    export GAME_ARG="tf"
elif [ "${GAME}" == "hl2dm" ]
then
    echo "detected Half-Life 2: Deathmatch"
    export GAME_DIR=${HL2DM_SERVER_DIR}
    export GAME_ARG="hl2mp"
else
    echo "Invalid GAME property: \"${GAME}\""
    exit 1
fi

if [ ! "${WORKSHOP_COLLECTION}" == "" ]
then
    echo "Workshop collection ${WORKSHOP_COLLECTION} will be used."
    export WORKSHOP_COLLECTION_ARG="+host_workshop_collection ${WORKSHOP_COLLECTION}"
else
    echo "No Workshop collection will be hosted"
fi


# docker sends a SIGTERM and then SIGKILL to the main process
# Valheim needs a SIGINT (CTRL+C) to terminate properly
function shutdownServerGracefully()
{
    echo "server PID is: $1"
    # send a SIGINT to shut down the Valheim server gracefully
    kill -2 $1
    # wait for Valheim to terminate before shutting down the container
    wait $1
    exit 0
}

# catch Docker's SIGTERM, then then a SIGINT to the Valheim server process
trap 'shutdownServerGracefully "$SERVER_PID"' SIGTERM

export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

echo "Starting server PRESS CTRL-C to exit"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

echo "GAME is: ${GAME}"
echo "MAP is: ${MAP}"
echo "MAX_PLAYERS is: ${MAX_PLAYERS}"
echo "SERVER_TOKEN is: ${SERVER_TOKEN}"
echo "WORKSHOP_COLLECTION is: ${WORKSHOP_COLLECTION}"
echo "WORKSHOP_COLLECTION_ARG is: ${WORKSHOP_COLLECTION_ARG}"

echo "GAME_PORT is: ${GAME_PORT}"
echo "SOURCETV_PORT is: ${SOURCETV_PORT}"
echo "CLIENT_PORT is: ${CLIENT_PORT}"
echo "STEAM_PORT is: ${STEAM_PORT}"


mkdir -p ${GMOD_SERVER_DIR}
mkdir -p ${CSS_SERVER_DIR}
mkdir -p ${TF2_SERVER_DIR}
mkdir -p ${HL2DM_SERVER_DIR}


steamcmd/steamcmd.sh +login anonymous \
+force_install_dir ${GMOD_SERVER_DIR} \
+app_update 4020 validate \
+force_install_dir ${CSS_SERVER_DIR} \
+app_update 232330 validate \
+force_install_dir ${TF2_SERVER_DIR} \
+app_update 232250 validate \
+force_install_dir ${HL2DM_SERVER_DIR} \
+app_update 232370 validate \
+exit > "${ROOT_SERVER_DIR}/steamcmd_log.txt"


# TODO if not existent: copy config files

cd ${GAME_DIR}

${GAME_DIR}/srcds_run -game ${GAME_ARG} +maxplayers ${MAX_PLAYERS} +map ${MAP} ${WORKSHOP_COLLECTION_ARG} +sv_setsteamaccount ${SERVER_TOKEN} -port ${GAME_PORT} +tv_port ${SOURCETV_PORT} -clientport ${CLIENT_PORT} -sport ${STEAM_PORT} &
SERVER_PID=$!
echo "Server PID is: $SERVER_PID"


# since the server is run in the background, this is needed to keep the main process from exiting
while wait $!; [ $? != 0 ]; do true; done

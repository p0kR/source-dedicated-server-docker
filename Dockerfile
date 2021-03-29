FROM cm2network/steamcmd:latest


ENV STEAM_HOME_DIR "/home/steam"

# where the server is installed to
ENV ROOT_SERVER_DIR "${STEAM_HOME_DIR}/root-dir"
ENV GMOD_SERVER_DIR "${ROOT_SERVER_DIR}/gmod_ds"
ENV CSS_SERVER_DIR "${ROOT_SERVER_DIR}/css_ds"
ENV TF2_SERVER_DIR "${ROOT_SERVER_DIR}/tf2_ds"
ENV HL2DM_SERVER_DIR "${ROOT_SERVER_DIR}/hl2dm_ds"

# changes the uuid and guid to 1000:1000, allowing for the files to save on GNU/Linux
USER 1000:1000

# don't change the port unless you know what you are doing
ENV GAME_PORT 27015
ENV SOURCETV_PORT 27020
ENV CLIENT_PORT 27005
ENV STEAM_PORT 26900

ENV GAME terrortown
ENV MAP gm_flatgrass
ENV MAX_PLAYERS 16
ENV SERVER_TOKEN IAmAnInvalidKey

# the server needs these 4 ports exposed by default
EXPOSE 1200/tcp
EXPOSE 1200/udp
EXPOSE 27005-27015/udp
EXPOSE 27015/tcp
EXPOSE 27020/udp
EXPOSE 26900/udp

VOLUME ${ROOT_SERVER_DIR}

# copy over the modified server start script
COPY start-source-dedicated-server.sh ${STEAM_HOME_DIR}
WORKDIR ${STEAM_HOME_DIR}

ENTRYPOINT ["./start-source-dedicated-server.sh"]

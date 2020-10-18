FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    unzip \
    dos2unix \
    wget \
    x11vnc \
    xvfb \
    openjfx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN wget -q --progress=bar:force:noscroll --show-progress https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh -O install-ib.sh && \
    chmod a+x install-ib.sh && \
    yes '' | ./install-ib.sh && \
    rm install-ib.sh

RUN wget -q --progress=bar:force:noscroll --show-progress https://github.com/IbcAlpha/IBC/releases/download/3.8.4-beta.1/IBCLinux-3.8.4-beta.1.zip -O ibc.zip && \
    unzip ibc.zip -d /opt/ibc && \
    chmod a+x /opt/ibc/*.sh /opt/ibc/*/*.sh && \
    rm ibc.zip

COPY run.sh run.sh
RUN dos2unix run.sh

RUN mkdir .vnc && \
    x11vnc -storepasswd 1358 .vnc/passwd

COPY ibc_config.ini ibc/config.ini

ENV DISPLAY :0
ENV TRADING_MODE paper
ENV TWS_PORT 4002
ENV VNC_PORT 5900
ENV TZ "US/Eastern"

EXPOSE $TWS_PORT
EXPOSE $VNC_PORT

CMD ./run.sh

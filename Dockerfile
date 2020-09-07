# Builder
FROM ubuntu:latest AS builder

RUN apt-get update
RUN apt-get install -y unzip dos2unix wget

WORKDIR /root

RUN wget -q --progress=bar:force:noscroll --show-progress https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh -O install-ib.sh
RUN chmod a+x install-ib.sh

RUN wget -q --progress=bar:force:noscroll --show-progress https://github.com/IbcAlpha/IBC/releases/download/3.8.4-beta.1/IBCLinux-3.8.4-beta.1.zip -O ibc.zip
RUN unzip ibc.zip -d /opt/ibc
RUN chmod a+x /opt/ibc/*.sh /opt/ibc/*/*.sh

COPY run.sh run.sh
RUN dos2unix run.sh

# Application
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y x11vnc xvfb socat

WORKDIR /root

COPY --from=builder /root/install-ib.sh install-ib.sh
RUN yes '' | ./install-ib.sh

RUN mkdir .vnc
RUN x11vnc -storepasswd 1358 .vnc/passwd

COPY --from=builder /opt/ibc /opt/ibc
COPY --from=builder /root/run.sh run.sh

COPY ibc_config.ini ibc/config.ini

ENV DISPLAY :0
ENV TRADING_MODE paper
ENV TWS_PORT 4002
ENV VNC_PORT 5900

EXPOSE $TWS_PORT
EXPOSE $VNC_PORT

CMD ./run.sh

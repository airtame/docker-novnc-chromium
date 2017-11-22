FROM alpine:edge
MAINTAINER Airtame "ops@airtame.com"

ENV VNC_PORT=5901 \
    NO_VNC_PORT=6080
EXPOSE $VNC_PORT $NO_VNC_PORT

# Setup testing repo
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install basic packages
RUN apk --update --no-cache add py-numpy chromium x11vnc novnc xvfb openbox supervisor sudo xfce4-terminal wget ca-certificates && \
    update-ca-certificates

# Fix novnc index.html
RUN ln -s /usr/share/novnc/vnc_auto.html /usr/share/novnc/index.html

# Copy patched files
COPY novnc/vnc_auto.html  /usr/share/novnc/
COPY novnc/include/rfb.js /usr/share/novnc/include

# Setup basic environment
ENV TERM=xterm \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1920x1080 \
    VNC_PW=Test1234 \
    VNC_VIEW_ONLY=false \
    URL="https://airtame.com"

# Add new user
RUN addgroup headless && adduser -G headless -s /bin/sh -D headless

# Add supervisord
COPY supervisord.conf /etc/supervisord.conf
USER headless

# Entrypoint
CMD ["/usr/bin/supervisord","-j","/tmp/supervisord.pid","-l","/home/headless/supervisord.log","-c","/etc/supervisord.conf"]

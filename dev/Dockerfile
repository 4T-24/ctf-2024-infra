#
# Ubuntu Bionic + Systemd + sshd
#
# Usage:
#
# $ docker run --runtime=sysbox-runc -it --rm -P --name=syscont nestybox/ubuntu-bionic-systemd-docker
#
# This will run systemd and prompt for a user login; the default
# user/password in this image is "admin/admin". Once you log in you
# can run Docker inside as usual. You can also ssh into the image:
#
# $ ssh admin@<host-ip> -p <host-port>
#
# where <host-port> is chosen by Docker and mapped into the system container's sshd port.
#

FROM ghcr.io/nestybox/ubuntu-bionic-systemd:latest

ARG is

# Install Sshd
RUN apt-get update && apt-get install --no-install-recommends -y openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /home/admin/.ssh \
    && chown admin:admin /home/admin/.ssh

# Install curl
RUN apt-get update && apt-get install --no-install-recommends -y curl

# Allow admin to run sudo without password
RUN echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin && \
    echo "admin:$is" | chpasswd

# Randomize machine-id
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && dbus-uuidgen --ensure

EXPOSE 22

# Set systemd as entrypoint.
ENTRYPOINT [ "/sbin/init", "--log-level=err" ]
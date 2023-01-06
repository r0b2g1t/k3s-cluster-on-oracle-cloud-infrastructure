################################################################################
# Commands to install Fedora CoreOS on Server 0.
################################################################################
sudo dnf install podman butane

podman container run --interactive \
    --rm quay.io/coreos/butane:release \
    --pretty --strict < k3s-server-0.bu > k3s-server-0.ign

sudo wipefs -a /dev/sdb

sudo podman run --pull=always --privileged --rm \
    -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    install /dev/sdb --architecture aarch64 -i k3s-server-0.ign
    # The --copy-network flag can be used to copy the network from the host.


################################################################################
# Commands to install Fedora CoreOS on Server 1.
################################################################################
sudo dnf install podman butane

podman container run --interactive \
    --rm quay.io/coreos/butane:release \
    --pretty --strict < k3s-server-1.bu > k3s-server-1.ign

sudo wipefs -a /dev/sdc

sudo podman run --pull=always --privileged --rm \
    -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    install /dev/sdc --architecture aarch64 -i k3s-server-1.ign
    # The --copy-network flag can be used to copy the network from the host.


################################################################################
# Commands to install Fedora CoreOS on Agent 0.
################################################################################
sudo dnf install podman butane

podman container run --interactive \
    --rm quay.io/coreos/butane:release \
    --pretty --strict < k3s-agent-0.bu > k3s-agent-0.ign

sudo wipefs -a /dev/sdd

sudo podman run --pull=always --privileged --rm \
    -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    install /dev/sdd --architecture x86_64 -i k3s-agent-0.ign
    # The --copy-network flag can be used to copy the network from the host.


################################################################################
# Commands to install Fedora CoreOS on Agent 1.
################################################################################
sudo dnf install podman butane

podman container run --interactive \
    --rm quay.io/coreos/butane:release \
    --pretty --strict < fcos.bu > config.ign

sudo wipefs -a /dev/sdb

sudo podman run --pull=always --privileged --rm \
    -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    install /dev/sdb --architecture x86_64 -i config.ign
    # The --copy-network flag can be used to copy the network from the host.

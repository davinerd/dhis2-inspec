
LXC_CONTAINER="$1"

TEST="$2"

container=`lxc list | grep -w $LXC_CONTAINER`

if ! [ "$container" ]; then
    echo "[X] Error: container $LXC_CONTAINER not found!"
    exit 1
fi


echo -e "[*] Copying file"
lxc file push "$TEST" "${LXC_CONTAINER}/tmp/"

inspec_installed=`lxc exec "${LXC_CONTAINER}" -- which inspec`
if ! [ "$inspec_installed" ]; then
    echo -e "\n[*] Installing inspect"
    lxc exec "${LXC_CONTAINER}" -- bash -c "curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec"
fi

echo -e "\n[*] Run inspec"
TEST_FILE=`basename "${TEST}"`
lxc exec "${LXC_CONTAINER}" -- inspec exec /tmp/${TEST_FILE} --chef-license=accept-silent

echo -e "\n[*]Clean up test file"
lxc exec "${LXC_CONTAINER}" -- rm -rf /tmp/${TEST_FILE}

# TODO: add option to uninstall inspec from lxc container

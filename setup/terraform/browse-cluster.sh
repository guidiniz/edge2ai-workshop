#!/bin/bash
# Works on MacOS only
set -o errexit
set -o nounset
BASE_DIR=$(cd $(dirname $0); pwd -L)
. $BASE_DIR/common.sh

if [ $# != 2 -a $# != 3 ]; then
  echo "Syntax: $0 <namespace> <cluster_number>"
  show_namespaces
  exit 1
fi
NAMESPACE=$1
CLUSTER_ID=$2
PROXY_PORT=${3:-}
load_env $NAMESPACE

PUBLIC_DNS=$(public_dns $CLUSTER_ID)
if [ "$PUBLIC_DNS" == "" ]; then
  echo "ERROR: Cluster ID $CLUSTER_ID not found."
  exit 1
fi

PUBLIC_IP=$(public_ip $CLUSTER_ID)
if [ "$PROXY_PORT" != "" ]; then
  PROXY_PORT="--proxy-server=socks5://localhost:$PROXY_PORT"
fi

rm -rf $HOME/chrome-for-demo
mkdir $HOME/chrome-for-demo
touch "$HOME/chrome-for-demo/First Run"

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --user-data-dir="$HOME/chrome-for-demo" \
  --window-size=1184,854 \
  $PROXY_PORT \
  http://$PUBLIC_DNS:7180 \
  http://$PUBLIC_DNS:10080/efm/ui \
  http://$PUBLIC_DNS:8080/nifi/ \
  http://$PUBLIC_DNS:18080/nifi-registry \
  http://$PUBLIC_DNS:7788 \
  http://$PUBLIC_DNS:9991 \
  http://$PUBLIC_DNS:8888 \
  http://cdsw.$PUBLIC_IP.nip.io


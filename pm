#! /bin/sh

init() {

echo "rdr pass on lo0 inet proto tcp from any to any port 80 -> 127.0.0.1 port $1 
rdr pass on en0 inet proto tcp from any to any port 80 -> 127.0.0.1 port $1 
" | sudo tee /etc/pf.anchors/com.pow


sudo tee /etc/pf.conf > /dev/null <<'EOF'
#
# com.apple anchor point
#
scrub-anchor "com.apple/*"
nat-anchor "com.apple/*"
rdr-anchor "com.apple/*"
rdr-anchor "pow"
dummynet-anchor "com.apple/*"
anchor "com.apple/*"
load anchor "com.apple" from "/etc/pf.anchors/com.apple"
load anchor "pow" from "/etc/pf.anchors/com.pow"

EOF

start
}

start() {
    sudo pfctl -f /etc/pf.conf
    sudo pfctl -e
}

setPort() {
    read -p "What port is mapped to port 80  " port
    [ -z "$port" ] && port=8080
    
    return $port
}

echo "What do you want to do?"
echo "-> 1. For the first time to configure and start"
echo "-> 2. Start"
read -p "Select the numbers 1, 2? (The default is 1)  " selectNum
[ -z "$selectNum" ] && selectNum=1

if [ "$selectNum" == '1' ];then
    setPort 
    init $port
else 
    start
fi

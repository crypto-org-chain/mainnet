#!/usr/bin/env bash

set -e

download_genesis()
{
    echo_s "💾 Downloading $NETWORK genesis"
    curl -sS $NETWORK_URL/$NETWORK/genesis.json -o $CM_GENESIS
}
shopt -s globstar
download_binary()
{
    echo_s "💾 Downloading $NETWORK binary"
    TEMP_DIR="$(mktemp -d)"
    curl -LJ $(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".binary | .[] | select(.version==\"$CM_DESIRED_VERSION\").linux.link") -o $TEMP_DIR/chain-maind.tar.gz
    CHECKSUM=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".binary | .[] | select(.version==\"$CM_DESIRED_VERSION\").linux.checksum")
    if (! echo "$CHECKSUM $TEMP_DIR/chain-maind.tar.gz" | sha256sum -c --status --quiet - > /dev/null 2>&1) ; then
        echo_s "The checksum does not match the target downloaded file! Something wrong from download source, please try again or create an issue for it."
        exit 1
    fi
    tar -xzf $TEMP_DIR/chain-maind.tar.gz -C $TEMP_DIR
    mv $TEMP_DIR/**/chain-maind $CM_BINARY
    rm -rf $TEMP_DIR
}
DaemonReloadFunction()
{
    sudo systemctl daemon-reload
}
EnableFunction()
{
    DaemonReloadFunction
    sudo systemctl enable chain-maind.service
}
StopService()
{
    # Stop service
    echo_s "Stopping chain-maind service"
    sudo systemctl stop chain-maind.service
}
# Regenerate priv_validator_key.json
RegenerateValidatorKey()
{
    rm -f $CM_HOME/config/priv_validator_key.json;
    echo_s "A new priv_validator_key.json with pubkey: \033[32m$($CM_BINARY tendermint show-validator --home $CM_HOME 2>&1)\033[0m\n"
}
# Regenerate node_key.json
RegenerateNodeKeyJSON()
{
    echo_s "Generate and replace node_key in $NODE_KEY_PATH\n"
    rm -f $CM_HOME/config/node_key.json
    TEMP_DIR=$(mktemp -d)
    $CM_BINARY init test --home $TEMP_DIR > /dev/null 2>&1
    mv $TEMP_DIR/config/node_key.json $CM_HOME/config/node_key.json
    rm -rf $TEMP_DIR
    ShowNodeKeyInfo
}
# print node_key and node_id
ShowNodeKeyInfo()
{
    NODE_ID=$($CM_BINARY tendermint show-node-id --home $CM_HOME)
    NODE_KEY=$(cat $NODE_KEY_PATH | jq .priv_key.value -r)
    echo_s "You may want to save node_id and node_key for later use\n"
    echo_s "node_id: \033[32m$NODE_ID\033[0m\n"
    echo_s "node_key: \033[32m$NODE_KEY\033[0m\n"
}
# allow gossip this ip
AllowGossip()
{
    # find IP
    IP=$(curl -s http://checkip.amazonaws.com)
    if [[ -z "$IP" ]] ; then
        read -p 'What is the public IP of this server?: ' IP
    fi
    echo_s "✅ Added public IP to external_address in chain-maind config.toml for p2p gossip\n"
    sed -i "s/^\(external_address\s*=\s*\).*\$/\1\"$IP:26656\"/" $CM_CONFIG
}
EnableStateSync()
{
    RPC_SERVERS=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".endpoint.rpc")
    LASTEST_HEIGHT=$(curl -s $RPC_SERVERS/block | jq -r .result.block.header.height)
    BLOCK_HEIGHT=$((LASTEST_HEIGHT - 300))
    TRUST_HASH=$(curl -s "$RPC_SERVERS/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
    PERSISTENT_PEERS=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".persistent_peers")
    IFS=',' read -r -a array <<< "$PERSISTENT_PEERS"
    peer_size=${#array[@]}
    index1=$(($RANDOM % $peer_size))
    index2=$(($RANDOM % $peer_size))
    PERSISTENT_PEERS="${array[$index1]},${array[$index2]}"
    sed -i "s/^\(seeds\s*=\s*\).*\$/\1\"\"/" $CM_CONFIG
    sed -i "s/^\(persistent_peers\s*=\s*\).*\$/\1\"$PERSISTENT_PEERS\"/" $CM_CONFIG
    sed -i "s/^\(trust_height\s*=\s*\).*\$/\1$BLOCK_HEIGHT/" $CM_CONFIG
    sed -i "s/^\(trust_hash\s*=\s*\).*\$/\1\"$TRUST_HASH\"/" $CM_CONFIG
    sed -i "s/^\(enable\s*=\s*\).*\$/\1true/" $CM_CONFIG
    sed -i "s|^\(rpc_servers\s*=\s*\).*\$|\1\"$RPC_SERVERS,$RPC_SERVERS\"|" $CM_CONFIG
}
DisableStateSync()
{
    sed -i "s/^\(enable\s*=\s*\).*\$/\1false/" $CM_CONFIG
}
shopt -s extglob
checkout_network()
{
    mapfile -t arr < <(curl -sS $NETWORK_JSON | jq -r 'keys[]')
    echo_s "You can select the following networks to join"
    for i in "${!arr[@]}"; do
        printf '\t%s. %s\n' "$i" "${arr[i]}"
    done

    read -p "Please choose the network to join by index (0/1/...): " index
    case $index in
        +([0-9]))
            if [[ $index -gt $((${#arr[@]} - 1)) ]]; then
                echo_s "Larger than the max index"
                exit 1
            fi
            NETWORK=${arr[index]}
            echo_s "The selected network is $NETWORK"
            GENESIS_TARGET_SHA256=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".genesis_sha256sum")
            if [[ ! -f "$CM_GENESIS" ]] || (! echo "$GENESIS_TARGET_SHA256 $CM_GENESIS" | sha256sum -c --status --quiet - > /dev/null 2>&1) ; then
                echo_s "The genesis does not exit or the sha256sum does not match the target one. Download the target genesis from github."
                download_genesis
            fi
            SEEDS=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".seeds")
            sed -i "s/^\(seeds\s*=\s*\).*\$/\1\"$SEEDS\"/" $CM_CONFIG
            read -p "Do you want to enable state-sync? (Y/N): " yn
            case $yn in
                [Yy]* ) 
                    echo_s "State-sync require the latest version of binary to state-sync from the latest block."
                    EnableStateSync
                    CM_DESIRED_VERSION=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".latest_version")
                ;;
                * ) 
                    echo_s "Normal-sync require the preceding version of binary to sync from scratch."
                    DisableStateSync
                    CM_DESIRED_VERSION=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".binary | .[0].version")
                ;;
            esac
            if [[ ! -f "$CM_BINARY" ]] || [[ $($CM_BINARY version 2>&1) != $CM_DESIRED_VERSION ]]; then
                echo_s "The binary does not exist or the version does not match the target version. Download the target version binary from github release."
                download_binary
            fi
        ;;
        *)
            echo_s "No match"
            exit 1
        ;;
    esac
}
echo_s()
{
    echo -e $1
}

if ! [ -x "$(command -v jq)" ]; then
    echo 'jq not installed! Installing jq' >&2
    sudo apt update
    sudo apt install jq -y
fi


# Select network
NETWORK_URL="https://raw.githubusercontent.com/crypto-org-chain/mainnet/main"
NETWORK_JSON="$NETWORK_URL/mainnet.json"
CM_HOME="/chain/.chain-maind"
CM_CONFIG="$CM_HOME/config/config.toml"
CM_BINARY="/chain/bin/chain-maind"
CM_GENESIS="$CM_HOME/config/genesis.json"
checkout_network

# Remove old data
echo_s "Reset chain-maind and remove data if any"
if [[ -d "$CM_HOME/data" ]]; then
    read -p '❗️ Enter (Y/N) to confirm to delete any old data: ' yn
    case $yn in
        [Yy]* ) StopService; $CM_BINARY unsafe-reset-all --home $CM_HOME;;
        * ) echo_s "Not delete and exit\n"; exit 0;;
    esac
fi

# Regenerate validator key
VALIDATOR_KEY="$CM_HOME/config/priv_validator_key.json"
if [[ -f "$VALIDATOR_KEY" ]]; then
    read -p "❗️ $VALIDATOR_KEY already exists! Do you want to override old key? (Y/N): " yn
    case $yn in
        [Yy]* ) RegenerateValidatorKey;;
        * )  "Keep the original priv_validator_key.json in $VALIDATOR_KEY with pubkey: \033[32m$($CM_BINARY tendermint show-validator --home $CM_HOME 2>&1)\033[0m";;
    esac
else
    RegenerateValidatorKey
fi
echo_s "💡 Please make sure you have a backup of $VALIDATOR_KEY in case of unexpected accidents!\n"

# Config .chain-maind/config/config.toml
echo_s "Replace moniker in $CM_CONFIG"
echo_s "Moniker is display name for tendermint p2p\n"
while true
do
    read -p 'moniker: ' MONIKER

    if [[ -n "$MONIKER" ]] ; then
        sed -i "s/^\(moniker\s*=\s*\).*\$/\1\"$MONIKER\"/" $CM_CONFIG
        DENOM=$(curl -sS $NETWORK_JSON | jq -r ".\"$NETWORK\".denom")
        sed -i "s/^\(\s*\[\"chain_id\",\s*\).*\$/\1\"$NETWORK\"],/" $CM_HOME/config/app.toml
        sed -i "s/^\(minimum-gas-prices\s*=\s*\"[0-9]\+\.[0-9]\+\).*\$/\1$DENOM\"/" $CM_HOME/config/app.toml

        read -p "Do you want to add the public IP of this node for p2p gossip? (Y/N): " yn
        case $yn in
            [Yy]* ) AllowGossip;;
            * )
                echo_s "WIll keep 'external_address value' empty\n";
                sed -i "s/^\(external_address\s*=\s*\).*\$/\1\"\"/" $CM_CONFIG;;
        esac
        break
    else
        echo_s "moniker is not set. Try again!\n"
    fi

done

# generate new node id and node key
NODE_KEY_PATH="$CM_HOME/config/node_key.json"
if [[ -f "$NODE_KEY_PATH" ]]; then
    read -p "$NODE_KEY_PATH already exists! Do you want to override old node_key.json? (Y/N): " yn
    case $yn in
        [Yy]* ) RegenerateNodeKeyJSON;;
        * ) echo_s "Keep the original node_key.json in $NODE_KEY_PATH\n"; ShowNodeKeyInfo;;
    esac
else
    RegenerateNodeKeyJSON
fi

# Restart service
echo_s "👏🏻 Restarting chain-maind service\n"
# Enable systemd service for chain-maind
EnableFunction
sudo systemctl restart chain-maind.service
sudo systemctl restart rsyslog

echo_s "👀 View the log by \"\033[32mjournalctl -u chain-maind.service -f\033[0m\" or find in /chain/log/chain-maind/chain-maind.log"
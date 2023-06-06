# Crypto.org Chain Mainnet

This repo collects the genesis, configuration files and script for the Crypto.org chain
mainnet.

## Getting Started

To get started with the mainnet, see the
[docs](https://crypto.org/docs/getting-started/).

## Mainnet Status


- *March 25, 2021 01:00:00 UTC* - [crypto-org-chain-mainnet-1](./crypto-org-chain-mainnet-1)

[mainnet.json](./mainnet.json) lists the mainnet information.


## Persistent Peers for State Sync

If you want to enable state sync, you can add some of the following nodes to your persistent peers list

```
- `87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.crypto.org:26656` - Crypto.org
- `e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.crypto.org:26656` - Crypto.org
- `2c55809558a4e491e9995962e10c026eb9014655@seed-2.crypto.org:26656` - Crypto.org 
```

## Seed Nodes

A list of seeds from Crypto.org. Please make sure you add them to `seeds` in `config.toml` **but not** `persistent_peers`.

```
Seed nodes
- `87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.crypto.org:26656` - Crypto.org
- `e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.crypto.org:26656` - Crypto.org
- `2c55809558a4e491e9995962e10c026eb9014655@seed-2.crypto.org:26656` - Crypto.org 
```

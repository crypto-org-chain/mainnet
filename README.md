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
- `87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.cronos-pos.org:26656`
- `e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.cronos-pos.org:26656`
- `2c55809558a4e491e9995962e10c026eb9014655@seed-2.cronos-pos.org:26656`
```

## Seed Nodes

A list of seeds from Crypto.org. Please make sure you add them to `seeds` in `config.toml` **but not** `persistent_peers`.

### Cronos POS Mainnet - `crypto-org-chain-mainnet-1`
```
87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.cronos-pos.org:26656,e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.cronos-pos.org:26656,2c55809558a4e491e9995962e10c026eb9014655@seed-2.cronos-pos.org:26656
```
### Cronos POS Testnet - `testnet-croeseid-4`
```
"71d2a4727bf574d5d368c343e37edff00cd556b1@seed-0.testnet-croeseid-4.cronos-pos.org:26656,8af7c92277f3edce58aa828cf1026cfa74fd6569@seed-1.testnet-croeseid-4.cronos-pos.org:26656"
```

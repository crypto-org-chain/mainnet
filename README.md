# Crypto.org Chain Mainnet

This repo collects the genesis, configuration files and script for the Crypto.org chain
mainnet.

## Getting Started

To get started with the mainnet, see the
[docs](https://crypto.org/docs/getting-started/).

## Mainnet Status


- *March 25, 2020 01:00:00 UTC* - [crypto-org-chain-mainnet-1](./crypto-org-chain-mainnet-1)

[mainnet.json](./mainnet.json) lists the mainnet information.


## Persistent Peers for State Sync

If you want to enable state sync, you can add some of the following nodes to your persistent peers list

```
- `87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.crypto.org:26656` - Crypto.org
- `e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.crypto.org:26656` - Crypto.org
- `2c55809558a4e491e9995962e10c026eb9014655@seed-2.crypto.org:26656` - Crypto.org 
```

## Seed Nodes

A list of seeds from Crypto.org and Bison Trails. Please make sure you add them to `seeds` in `config.toml` **but not** `persistent_peers`.

```
Seed nodes

- `8dc1863d1d23cf9ad7cbea215c19bcbe8bf39702@p2p.baaa7e56-cc71-4ae4-b4b3-c6a9d4a9596a.cryptodotorg.bison.run:26656` - Bison Trails
- `8a7922f3fb3fb4cfe8cb57281b9d159ca7fd29c6@p2p.aef59b2a-d77e-4922-817a-d1eea614aef4.cryptodotorg.bison.run:26656` - Bison Trails
- `494d860a2869b90c458b07d4da890539272785c9@p2p.fabc23d9-e0a1-4ced-8cd7-eb3efd6d9ef3.cryptodotorg.bison.run:26656` - Bison Trails
- `dc2540dabadb8302da988c95a3c872191061aed2@p2p.7d1b53c0-b86b-44c8-8c02-e3b0e88a4bf7.cryptodotorg.herd.run:26656` - Bison Trails
- `33b15c14f54f71a4a923ac264761eb3209784cf2@p2p.0d20d4b3-6890-4f00-b9f3-596ad3df6533.cryptodotorg.herd.run:26656` - Bison Trails
- `d2862ef8f86f9976daa0c6f59455b2b1452dc53b@p2p.a088961f-5dfd-4007-a15c-3a706d4be2c0.cryptodotorg.herd.run:26656` - Bison Trails
- `87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.crypto.org:26656` - Crypto.org
- `e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.crypto.org:26656` - Crypto.org
- `2c55809558a4e491e9995962e10c026eb9014655@seed-2.crypto.org:26656` - Crypto.org 
```

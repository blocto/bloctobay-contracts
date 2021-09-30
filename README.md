# BloctoBay Contracts

## Setup Flow CLI
https://docs.onflow.org/flow-cli/install

## Run Script

### Get All Listings on Marketplace

```
// offset
// limit

flow scripts execute ./scripts/Marketplace/getListings.cdc \
    --arg Int:0 \
    --arg Int:20
```

### Get All NFTs and Listings By Address

```
flow scripts execute scripts/getUserNFTsAndListings.cdc \
    --arg Address:0xe03daebed8ca0615
```

### Get Single Listing By NFT ID

```
flow scripts execute scripts/NFTs/*/getListing.cdc \
    --arg UInt64:0
```

## Run Transactions

### Setup SaleCut Recipient

```
flow transactions send transactions/FTs/FUSD/setupAccount.cdc \
    --signer emulator-blocto-recipient
flow transactions send transactions/FTs/FUSD/setupAccount.cdc \
    --signer emulator-example-nft-recipient
```

### Setup FUSD

```
flow transactions send transactions/FTs/FUSD/setupAccount.cdc \
    --signer emulator-nft-user1
```

### Update SaleCutRequirements

```
flow transactions send transactions/Marketplace/updateSaleCutRequirements.cdc 0x179b6b1cb6755e31 0.025 0xf3fcd2c1a78f5eee 0.1 \
    --signer emulator-marketplace-admin
```

### Mint ExampleNFT

```
flow transactions send transactions/NFTs/ExampleNFT/setupAccount.cdc \
    --signer emulator-nft-user1
flow transactions send transactions/NFTs/ExampleNFT/mintToken.cdc 0xe03daebed8ca0615
```

### Sell Item

```
flow transactions send transactions/NFTs/ExampleNFT/sellItem.cdc 0 1.0 \
    --signer emulator-nft-user1
```

### Buy Item

```
flow transactions send transactions/NFTs/ExampleNFT/buyItem.cdc 52 0xe03daebed8ca0615 \
    --signer emulator-nft-user2
```

### Remove Item

It must be called by owner
```
flow transactions send transactions/removeItem.cdc 52 \
    --signer emulator-nft-user1
```

### Cleanup Item

Anyone can call it after the item has been purchased or transferred
```
flow transactions send transactions/cleanupItem.cdc 52
```
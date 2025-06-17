# Foundry Examples

# Example deploying ERC20 to Neon EVM Devnet using Foundry

This directory contains all the files necessary to deploy simplest ERC20-like contract using Neon onto the Solana blockchain.

## Prerequisites

To use this project, Foundry must be installed on the machine.

### Foundry installation

```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Cloning repository

Run command

```sh
git clone https://github.com/neonlabsorg/neon-foundry-tutorials.git
```

## Install the required libraries

```sh
cd neon-foundry-tutorials
forge install foundry-rs/forge-std
forge install openzeppelin/openzeppelin-contracts
```

## Setup Neon network in the Metamask wallet

1. Go to [Chainlist](https://chainlist.org/?search=Neon+EVM&testnets=true) and add the Neon EVM Devnet and Neon EVM Mainnet networks to your Metamask wallet.
2. Airdrop at most 100 NEONs to the created **account #1** [from here](https://neonfaucet.org/)
3. Copy your Metamask account's private key (Account Details >> Export Private Key) and insert them into **.env**
   **NOTE!** Add **0x** prefix at the beginning

## Set up .env file

```sh
cp .env.example .env
```

**Replace `XYZ` with the private key of your Metamask account in the .env file.**

Then run this -

```sh
source .env
```

## Building contracts and running tests on devnet

1. Compiling contract

```sh
forge build
```

2. Running tests

```sh
forge test
```

## Deploying contract, minting tokens, transferring tokens using Foundry Scripts

### Deploy contract

```sh
forge script script/TestERC20/DeployTestERC20.s.sol:DeployTestERC20Script --broadcast --rpc-url $RPC_URL_DEVNET --skip-simulation
```

### Mint tokens to the deployer account and transfer tokens from the deployer account to another account

Replace `testERC20Address` with the deployed TestERC20 contract from the previous step.

```sh
forge script script/TestERC20/MintTestERC20.s.sol:MintTestERC20Script --broadcast --rpc-url $RPC_URL_DEVNET --skip-simulation
```

> ⚠️ **Important:** `--skip-simulation` flag is mandatory for the `forge script` commands because on-chain simulation doesn't work on Neon EVM Devnet or Mainnet.

**_NOTE:_** The native token displayed above can be considered as NEON instead of ETH and the unit can be considered as Galan instead of gwei (It is not possible to customize the display).

## Deploying contract, minting tokens, transferring tokens without using Foundry Scripts

### Deploy contract

```sh
forge create --rpc-url $RPC_URL_DEVNET --private-key $PRIVATE_KEY src/TestERC20/TestERC20.sol:TestERC20 --broadcast --constructor-args "Test ERC20 Token" "TERC20" "<deployer_address>"
```

### Send a transaction with a deployed smart contract mint function

```sh
cast send <contract_address> --rpc-url $RPC_URL_DEVNET --private-key $PRIVATE_KEY "mint(address,uint256)" "<deployer_address>" 20000000000000000000
```

### Call a deployed smart contract function

```sh
cast call <contract_address> --rpc-url $RPC_URL_DEVNET "balanceOf(address) (uint256)" "<account_address>"
```

### Transfer the ERC20 token to another address

```sh
cast send <contract_address> --rpc-url $RPC_URL_DEVNET --private-key $PRIVATE_KEY "transfer(address,uint256)" "<receiver_address>" 100000000000000000
```

## Verify deployed contract on Blockscout

```sh
forge verify-contract --chain-id $CHAIN_ID_DEVNET <contract_address> src/TestERC20/TestERC20.sol:TestERC20 --verifier-url $VERIFIER_URL_BLOCKSCOUT --verifier blockscout
```

> ⚠️ **Important:** Fork testing won't work in the situations where there needs to be an interaction with the [custom precompiles](https://neonevm.org/docs/evm_compatibility/precompiles) on Neon EVM Devnet and Mainnet because they are not supported in the forked environment.

## Additional resources

1. [Foundry Documentation](https://getfoundry.sh/introduction/getting-started)
2. [Neon EVM Documentation](https://neonevm.org/docs/quick_start)

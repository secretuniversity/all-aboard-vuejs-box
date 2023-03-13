# All Aboard Secret Box

_(Brought to you by [Secret University](https://scrt.university))_

### Gitpod Workspace

Use the "Open in Gitpod" button below to launch the `All Aboard Secret Box` and follow along with the tutorial below.


[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/secretuniversity/all-aboard-vuejs-box)

## Getting Started
Welcome to the _All Aboard_ secret box.

This box will walk you through setting up a development environment (_in a sandbox)_ so you can start working with secret contracts!

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/secretuniversity/all-aboard-vuejs-box)

You should have the following three terminal tabs open in your sandbox environment:

1. `Secret Box Tutorial` - the _All Aboard_ tutorial is launched from this terminal
2. `LocalSecret Workspace` - this is where you'll launch the local Secret Network blockchain, getting to see it start and produce blocks
3. `Secret Contract Workspace` - as you go throught the tutorial, use this terminal to enter the commands to install, setup and interact with your secret contract

We will use **Linux/WSL** as the environment for the installation of requirements in this secret box. 

> If you'd like to setup your development environment on your laptop (instead of using a developer sandbox), follow the "Getting Started" steps [here](https://docs.scrt.network/secret-network-documentation/development/getting-started/setting-up-your-environment), which also covers Linux/WSL, Windows and Mac/OS installations. The official Secret Network guide includes:
> 
> - Setting Up Your Environment
> - Compile and Deploy
> - Running the Application
> - Interacting with the Testnet
#####

## Install Requirements

> Use the _Secret Contract Workspace_ terminal to install the following tools.

To follow along with the guide, we will be using:

- `make` (secret contract compilation)
- `rust` and `cargo` (Rust compilation and package management)

### Install Make

```bash
sudo apt-get install make
```

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Add WASM build target

```bash
source $HOME/.cargo/env
rustup target add wasm32-unknown-unknown
```

### Install Cargo Generate

Cargo generate is what you'll use to create a secret contract project, from a template. [Learn more about `cargo-generate` here](https://doc.rust-lang.org/cargo).

```bash
cargo install cargo-generate --features vendored-openssl
```

## LocalSecret

> Use the _LocalSecret Workspace_ terminal to install the following tools.

`LocalSecret` is a containerized version of Secret Network, suitable for development environments. [Learn more here](https://docs.scrt.network/secret-network-documentation/development/tools-and-libraries/local-secret).

### Install Docker

[Docker](https://docs.docker.com/get-docker) is an open platform for developing, shipping, and running applications.

> Follow the instructions for installing in a Linux/WSL environment.

### Pull LocalSecret Docker Image

Now that you have docker installed, pull the `LocalSecret` docker image.

```bash
docker pull ghcr.io/scrtlabs/localsecret:v1.8.0
```

### Run LocalSecret

Use the `docker run` command (below) to launch the `LocalSecret` blockchain. Once running, the container gets a name of "localsecret," which you'll reference when deploying a secret contract later in this tutorial.

```bash
docker run -it -p 9091:9091 -p 26657:26657 -p 1317:1317 -p 5000:5000 \
  --name localsecret ghcr.io/scrtlabs/localsecret:v1.8.0
```

![](https://i.imgur.com/K0O97Dh.png)

## SecretCLI

### Install SecretCLI

> Use the _Secret Contract Workspace_ terminal to install and run SecretCLI commands.

SecretCLI is a command-line tool that lets us interact with the Secret Network blockchain. It is used to send and query data as well as manage user keys and wallets.

```bash
wget https://github.com/scrtlabs/SecretNetwork/releases/download/v1.8.0/secretcli-Linux
chmod +x secretcli-Linux
sudo mv secretcli-Linux /usr/local/bin/secretcli
```

### Configure SecretCLI

Configuring `secretcli` to talk to the locally-running Secret Network instance.

> Notice we're setting the `keyring-backend` to `test` below. That helps with local development and testing because we won't need a password when using commands that require a signing wallet, such as deploying a contract. Normally, `keyring-backend` is set to `os` and is more secure.

```bash
secretcli config node http://localhost:26657
secretcli config chain-id secretdev-1
secretcli config keyring-backend test
secretcli config output json
```

For more information on `secretcli` commands, refer to the docs [here](https://docs.scrt.network/secret-network-documentation/development/tools-and-libraries/secret-cli).

### Get LocalSecret Status

With a `LocalSecret` instance running, use `secretcli` to query the status of the node.

```bash
secretcli status | jq
```

> The output is in JSON format, but `jq` makes it more readable by a human

![](https://i.imgur.com/IFO5z7M.png)


## Create Your Secret Contract

Now that you have `LocalSecret` running, it's time to create a secret contract!

### Generate the Project

We'll use the basic `counter` contract from the [Secret University github repo](https://github.com/secretuniversity/secret-template-cw1). This is the standard counter contract template, and has examples of querying and modifying a secret contract's state.

```bash
cargo generate --git https://github.com/secretuniversity/secret-template-cw1.git --name my-counter-contract
cd my-counter-contract
```

### Compile the Secret Contract

The project's `Makefile` defines how to compile the Rust contract to Web Assembly (_cosmwasm_), test and even deploy it to `LocalSecret`.

```bash
make build
```
> The Makefile has a `compress-wasm` target that is invoked after the contract is compiled which takes care of compressing the wasm and produces a `contract.wasm.gz` file.

### Run the Unit Tests

Run the contract's unit tests.

```bash
make test
```

## Storing the Contract

In order to store the compiled `contract.wasm.gz` to `LocalSecret`, we need to use a wallet funded with some SCRT. Transactions that modify contract state require a bit of gas in the form of the native SCRT token.

> This is `LocalSecret` SCRT, not to be confused with testnet or mainnet secret.

### Create a Wallet

`LocalSecret` comes with a set of [pre-defined wallets](https://docs.scrt.network/secret-network-documentation/development/tools-and-libraries/local-secret#accounts) you can use in development. Below, create a key for the pre-defined `a` wallet. 

> We're using the `--recover` flag which will prompt you for the mnemonic for the wallet.

```bash
secretcli keys add --recover myWallet
```

Enter the mnemonic when prompted:

```bash
> Enter your bip39 mnemonic
grant rice replace explain federal release fix clever romance raise often wild taxi quarter soccer fiber love must tape steak together observe swap guitar
```

If you've created the key successfully, you should see this output:

```bash
- name: a
  type: local
  address: secret1ap26qrlp8mcq2pg6r47w43l0y8zkqm8a450s03
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A07oJJ9n4TYTnD7ZStYyiPbB3kXOZvqIMkchGmmPRAzf"}'
  mnemonic: ""
```

### Query the Wallet's Balance

```bash
secretcli query bank balances secret1ap26qrlp8mcq2pg6r47w43l0y8zkqm8a450s03 | jq
```

The output from the bank balance query should look like this:

```bash
{
  "balances": [
    {
      "denom": "uscrt",
      "amount": "1000000000000000000"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "0"
  }
}
```

### Upload the Contract

Great! Now that you've got your wallet setup and it has plenty of funds, let's upload the contract code to the blockchain. Secret contracts get deployed to the network with their code and other information recorded. From there they must be created or "instantiated" in order to interact with them. 

> This is similar to object-oriented programming languages where you define a "class" (also like a blueprint) and create instances that are known as "objects" that represent real things such as smart contracts :-D.

```bash
secretcli tx compute store contract.wasm.gz --gas 5000000 --from myWallet
```

### Instantiate the Contract

In order to create a secret contract instance, we send an `instantiate` message, which creates it from the base contract code that's stored on the blockchain.

```bash
secretcli tx compute instantiate 1 '{"count": 1}' --from myWallet --label counterContract -y
```

### Running the Application

Now that you've stored and instantiated the counter contract, it's time to get some practice querying and executing transactions!

Follow the docs [here](https://docs.scrt.network/secret-network-documentation/development/getting-started/running-the-application).

## Next Steps

Congratulations on completing this _All Aboard Secret Box_ tutorial!
#####
We at [Secret University](https://scrt.university) hope you've enjoyed following the steps to setup your environment, and have learned a bit about working with secret contracts.
#####
Now that you've successfully learned how to setup your environment, run an instance of `LocalSecret`, and do some basic stuff with secret contracts, it's time to take things a bit further.
#####
To learn more about developing secret contracts, follow the _Secret Counter Box_ tutorial [here](https://scrt.university/repositories/secret-box/2/secret-counter). You'll also learn how to connect the frontend DApp to your `LocalSecret` instance to perform contract queries and transactions.

## Further Reading

- After going through this tutorial, we encourage you to go through this [Millionaire's Problem](hhttps://docs.scrt.network/secret-network-documentation/development/secret-by-example/millionaires-problem) breakdown for further learning on secret contracts.

- If you're new to the Rust programming language, check out the [Rust Book](https://doc.rust-lang.org/book/) or the [Rustlings](https://github.com/rust-lang/rustlings) course.

- Another fun way to learn Rust that's interactive is [Tour of Rust](https://tourofrust.com).

- Secret's CosmWasm is based on vanilla CosmWasm, but there are some differences due to the privacy capabilities of the network. However, the CosmWasm [docs](https://docs.cosmwasm.com/docs/1.0/) are still an excellent resource for anyone looking to develop smart contracts in the Cosmos ecosystem.

- For connecting the frontend to Secret Network and interacting, we recommend studying the [Secret.js](https://secretjs.scrt.network/) docs.

- If you're not familiar with Javascript or Typescript, we recommend these resources: 

    - [Learn Javascript Online](https://learnjavascript.online)
    - [Learn Typescript](https://www.typescriptlang.org/docs)

# Resources
- [Secret Network](https://docs.scrt.network) - official Secret Network documentation and guides
- [Secret IDE](https://www.digiline.io/) - an integration development environment specific to secret contracts
- [Gitpod](https://www.gitpod.io/docs) - Gitpod documentation
- [Vite](https://vitejs.dev/guide) - Guide on using Vite, a lean and fast development server
- [Vue](https://vuejs.org) - Progressive javascript framework

# Contributors
- Secret Agency - maintainers of the Secret Network documentation and much more!
- Laura SecretChainGirl [Github](https://github.com/secetchaingirl)
- Alex Sinplea [Github](https://github.com/sinplea) - frontend development
- Jeff SecretMickey - [Telegram](https://t.me/secretMickey) Lead UI/UX design
- Kate Unakatu [Telegram](https://t.me/unakatu) - UI/UX design and graphics (Loreum Ipsem and Geek.pics founding team member)


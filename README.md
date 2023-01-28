# staking-contracts

Smart contracts for Metad IBFT PoS

## How to start

```shell
$ git clone https://github.com/metaplayer-one/staking-contracts.git
$ cd staking-contracts
$ npm i
```

### Build contracts

```shell
$ npm run build
```

### Run unit tests

```shell
$ npm run test
```

### Stake balance to contract

Please make sure required values are set in .env to use this command

```shell
$ npm run stake
```

### Unstake from contract

```shell
$ npm run unstake
```

### Check current total staked amount and validators in contract

```shell
$ npm run info
```
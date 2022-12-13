❯ export STARKNET_NETWORK=alpha-goerli

❯ export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount

❯ starknet new_account

Account address: 0x07a6efce0524014fde2745e2340cdb6253312e35d71c7a4f2621ff99ba4f3d81
Public key: 0x07e691c6be9520ae1f56fb9787e68ae676765bd9bf97ef02fe6006f49e3402f1
Move the appropriate amount of funds to the account, and then deploy the account
by invoking the 'starknet deploy_account' command.

NOTE: This is a modified version of the OpenZeppelin account contract. The signature is computed
differently.

❯ starknet deploy_account

Sending the transaction with max_fee: 0.000005 ETH (5130074159217 WEI).
Sent deploy account contract transaction.

Contract address: 0x07a6efce0524014fde2745e2340cdb6253312e35d71c7a4f2621ff99ba4f3d81
Transaction hash: 0x16f46d2df521b9c2b5555a031082f6e9df8ce00f5a5120d0062b5fb92911d22


❯ starknet deploy_account --account tnv --max_fee=13056557553155

Sent deploy account contract transaction.

Contract address: 0x02aa1debc58cee5c74995a82b05f5ffda7d40cbbb026f7710c132e032c0cd41f
Transaction hash: 0x452e57bcaf2dbf59786482274bbfd02056839eb767790aa9cfbe10e968d3fcb

❯ starknet declare --contract artifacts/polynomial_lr.json --account tnv2

Sending the transaction with max_fee: 0.000002 ETH (1683921550125 WEI).
Declare transaction was sent.
Contract class hash: 0x2265b5272fcab5bdd7ff8215dbc192212b091b96db43174f2621bbb9afc238c
Transaction hash: 0x5e63e2bc9b695f0c376604d326674bfb6217ca1f7e3c5adb52dfda68416cce1
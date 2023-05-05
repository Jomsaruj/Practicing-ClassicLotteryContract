# Practicing-ClassicLotteryContract
This is my simple Solidity code for classic lottery smart contract problem.

## Requirements

The users should be able to interact with the lottery.sol contract as follows.

## In stage 1:

* This stage will last for time T1 seconds
* As many as N users can participate in the lottery
* T1 and N should be specified in the constructor of lottery.sol
* A user makes a transaction that submit the commitment of a value between 0 to 999, inclusive
* Every user submission transaction must provide msg.value of exactly 0.1 ETH
* After T1 seconds have elapsed, proceed to stage 2

## In stage 2:
* If no user participates in the lottery, the owner kills the contract
* Each user reveals the value in the commitment in stage 1
* If T2 seconds have passed since the start of stage 2 and a user fails to reveal his value, his fund is forfeited and goes to the winner. His value will not be used in determining the winner
* T2 is the value that should be specified in the constructor of lottery.sol
* After T2 seconds have elapsed, proceed to stage 3

# In stage 3:
* The owner of lottery.sol generates a transaction to determine the winner
* Use the all XORing and modulo as described in the lecture
* If a user submits an illegitimate number (the number outside 0 to 999 range), he can never be a winner; his fund is forfeited and will eventually go to the winner
* The winner receives 0.1 ETH * num_participants * 0.98 and the owner of lottery.sol receives 0.1 ETH * num_participants * 0.02. num_participants * represents the number of users participating in this lottery regardless of their actions being illegitimate or not. This value must be less than or equal to N.
* If the numbers submitted by all the users are illegitimate, the owner of lottery.sol takes all the ETHs sent to the contract by the users 
* If T3 seconds have passed since the start of stage 3 and the owner fails to submit a transaction to determine the winner, enter stage 4
T3 is the value that should be specified in the constructor of lottery.sol

## In stage 4:
* All the users who participated in the lottery can submit a transaction to get a full refund of their submitted funds.


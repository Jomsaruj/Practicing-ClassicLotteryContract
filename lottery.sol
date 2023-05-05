// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lottery {

    uint public T1; // time to wait for players (1st stage)
    uint public T2; // time to reveal secret number
    uint public T3; // time for owner to endgame
    uint public N; // max number of players
    uint public start_time; // max number of players

    uint public num_participants; // current number of participants
    uint public num_legitimate; // current number of legitimate participants
    uint public num_illegitimate; // current number of illegitimate participants
    address payable[] public participants; // List contain address of all participants
    address payable public owner;

    uint public total_fund; // valid fund

    mapping (address => bytes32) public hash_storage; // Store player hash
    mapping (address => uint) public value_storage;

    mapping (address => bool) public reveal_secret; // to check whether player reveal their secret or not
    mapping (address => bool) public legitimate_player; // to check whether player still legitimate or not
    mapping (address => bool) public refunded; // to check whether player refunded

    constructor(uint _T1, uint _T2, uint _T3, uint _N) {
        owner = payable(msg.sender);
        // unit = seconds
        T1 = _T1; 
        T2 = _T2; 
        T3 = _T3; 
        N = _N;
        start_time = block.timestamp;
    }

    function joinLotteryGame(uint _secret) public payable {

        require(msg.value == 100000000000000000, "Deposit value must equal to exact 0.1 ETH"); // 100000000000000000 wei = 0.1 eth
        require(num_participants < N, "Game is at its full capacity");
        require(block.timestamp <= T1 + start_time, "Game is already started");

        hash_storage[msg.sender] = sha256(abi.encodePacked(_secret)); // Store player hash
        participants.push(payable(msg.sender));
        num_participants += 1;
        total_fund += msg.value;
        refunded[msg.sender] = false;
        reveal_secret[msg.sender] = false;
        legitimate_player[msg.sender] = true;
        num_legitimate += 1;
    }

    function revealSecret(uint _value) public {
        require(block.timestamp > T1 + start_time, "Not enter reveal phase yet!");
        require(block.timestamp <= T1 + T2 + start_time, "Reveal period has passed");
        require(!reveal_secret[msg.sender], "already revealed");
        require(hash_storage[msg.sender] == sha256(abi.encodePacked(_value)), "Invalid secret value");

        value_storage[msg.sender] = _value;
        reveal_secret[msg.sender] = true;
    }

    function endGame() public {
        require(msg.sender == owner, "Only owner can endgame");
        require(block.timestamp > T1 + T2 + start_time, "Game in progress");
        require(block.timestamp <= T1 + T2 + T3 + start_time, "End game period has passed, players can refund");

        validateParticipants();

        if (num_legitimate == 0) {
            selfdestruct(owner);
            return;
        } 
        else {
            uint secretSum;

            for (uint i = 0; i < num_participants; i++) {
                if (legitimate_player[participants[i]]) {
                    secretSum ^= value_storage[participants[i]];
                }
            }
            
            uint result = secretSum % num_legitimate;

            uint count = 0;
            for (uint i = 0; i < num_participants; i++) {
                if (legitimate_player[participants[i]]) {
                    if (count == result) {
                        address payable winner = participants[i];
                        winner.transfer((total_fund * 98)/100);
                        owner.transfer((total_fund * 2)/100);
                        selfdestruct(owner);
                    }
                    count++;
                }
            }
        }
    }

    function refund() public {
        require(block.timestamp > T1 + T2 + T3 + start_time, "Not enter refund phase yet!");
        require(!refunded[msg.sender], "You have already refunded");
        payable(msg.sender).transfer(100000000000000000);
    }

    function validateParticipants() internal {
        for (uint i = 0; i < num_participants; i++) {
            if (value_storage[participants[i]] < 1000) {
                if(!reveal_secret[participants[i]]){
                    num_illegitimate += 1;
                    num_legitimate -= 1;
                    legitimate_player[participants[i]] = false;
                }

            } else {
                num_illegitimate += 1;
                num_legitimate -= 1;
                legitimate_player[participants[i]] = false;
            }
        }
    }
}
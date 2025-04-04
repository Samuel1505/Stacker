//  SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  event Stake(address indexed from, uint256 indexed deposit);

  ExampleExternalContract public exampleExternalContract;

  mapping (address => uint256) public balances;

  uint256 totalDeposit;

  uint256 public constant threshold = 1 ether;
  
  bool canWithdraw;
  uint256 public deadline = block.timestamp + 72 hours;

  modifier stakingNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "Staking period has completed");
    _;
  }
  

  constructor(address exampleExternalContractAddress) {
      canWithdraw = false;
      totalDeposit = 0;
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() external payable stakingNotCompleted {

      if(balances[msg.sender] == 0) {
        balances[msg.sender] = msg.value;
      } else {
        balances[msg.sender] = balances[msg.sender] + msg.value;
      }

      totalDeposit += msg.value;

      emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() external {
    require(block.timestamp >= deadline, "deadline not met, cannot execute");
    require(canWithdraw == false, "execute already called");

    if (totalDeposit >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      canWithdraw = true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() external payable stakingNotCompleted {
    require(canWithdraw, "deadline not met, cannot withdraw");
    if (totalDeposit < threshold) {
      uint256 userDeposit = balances[msg.sender];
      if (userDeposit > 0) {
        // (bool sent, bytes memory data) = msg.sender.call(userDeposit); 
        
        // (bool sent, ) = msg.sender.call(abi.encodeWithSignature("transfer(uint256)", userDeposit));
        address payable _to = payable(msg.sender);
        _to.transfer(userDeposit);

        // // check transfer was successful
        // require(sent, "Failed to send to address");

        totalDeposit -= userDeposit;
        balances[msg.sender] = 0;
      }
    }
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() external view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    this.stake();
  }

  function getBalance() external view returns (uint256) {
    return address(this).balance;
  }
  
}

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()

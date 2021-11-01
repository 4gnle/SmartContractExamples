//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract Coopefy {

  address public manager;

  constructor(address creator) {
    manager = creator;
  }

  struct Project {
    uint256 _value;
    address _creator;
    address _cooperator;
    bool approval;
  }

  modifier onlyCreator() {
      require(msg.sender == manager);
      _;
  }

  function createProject(uint256 value, address creator) public onlyCreator {
      Project storage p;
      p._value = value;
      p._creator = msg.sender;
  }

  function pickCooperator(address cooperator) public onlyCreator{
    Project storage projects = projects[index];


  }

  function approveProject(uint256 index) public onlyCreator {
    Project storage projects = projects[index];

    require(creator[msg.sender]);
    require(!project.approval);

    project.approval = true;
  }

  function finalizeProject(uint index) public onlyCreator {
    Project storage projects = projects[index];

    require(request.approvalCount >= (approversCount / 2));
    require(!request.complete);

    request.complete = true;
    request.recipient.transfer(request.value);
  }

}

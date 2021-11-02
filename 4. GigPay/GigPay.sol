//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract GigPay {

  address public creator;
  address payable public cooperator;

  constructor() {
    creator = msg.sender;
  }

  enum ProjectState {created, funded, accepted, finalized}

  struct Project {
    uint256 _value;
    address _creator;
    address payable _cooperator;
    bool _approval;
    ProjectState projectState;
  }

  modifier onlyCreator() {
      require(msg.sender == creator);
      _;
  }

  modifier onlyCooperator() {
      require(msg.sender == cooperator);
      _;
  }

  function createProject(uint256 value, address creatorAddress) public onlyCreator {
      Project memory p;
      p._value = value;
      p._creator = msg.sender;
      p.projectState = ProjectState.created;
  }

  function pickCooperator(address payable cooperatorAddress) public onlyCreator{
    Project memory p;
    p._cooperator = cooperatorAddress;
    cooperator = p._cooperator;
  }

  function acceptProject()
      public
      onlyCooperator
  {
    Project memory p;
      require(p._cooperator == cooperator);
      require(cooperator == msg.sender);
      p.projectState = ProjectState.accepted;
  }

  function fundProject()
    public
    payable
    onlyCreator
  {
  Project memory p;
    require(p.projectState == ProjectState.accepted);
    require(p._value != 0);
    require(msg.value == p._value, 'You need to fund with ');

    p.projectState = ProjectState.funded;
  }


  function approveProject() public onlyCreator {
    Project memory p;
    require(msg.sender == creator);
    require(!p._approval);
    p._approval = true;
  }

  function releaseFunds()
    public
    payable
    onlyCreator
{
  Project memory p;
    require(p.projectState == ProjectState.funded, 'You have not funded this project yet. There are no funds to release.');
    p._cooperator.transfer(p._value);
}

  function finalizeProject() public onlyCreator {
    Project memory p;
    require(p._approval == true);
    p.projectState = ProjectState.finalized;
  }

}

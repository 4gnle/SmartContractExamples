//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract GigPay {

  address public creator;
  address private owner;
  address payable public cooperator;

  constructor() {
    owner = msg.sender;
  }

  enum ProjectState {created, funded, accepted, finalized}

  struct Project {
    uint256 _value;
    address _creator;
    address payable _cooperator;
    bool _approval;
    ProjectState projectState;
  }

  Project[1] public activeProject;

  modifier onlyCreator() {
      require(msg.sender == creator);
      _;
  }

  modifier onlyCooperator() {
      require(msg.sender == cooperator);
      _;
  }

    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  function createProject(uint256 value) public view onlyCreator {

    activeProject.push(Project({
        ._value = value;
        _creator = msg.sender;
        projectState = ProjectState.created;
    }));
  }

  function pickCooperator(address payable cooperatorAddress) public onlyCreator{
    Project storage project = Project()

    require(Project._cooperator == address(0));
    require(cooperatorAddress != creator, 'You cannot set yourself as cooperator.');
    Project._cooperator = cooperatorAddress;
    cooperator = Project._cooperator;
  }

  function acceptProject()
      public
      view
      onlyCooperator
  {
      require(Project._cooperator == cooperator);
      Project.projectState = ProjectState.accepted;
  }

  function fundProject()
    public
    payable
    onlyCreator
  {
    require(Project.projectState == ProjectState.accepted);
    require(Project._value != 0);
    require(msg.value == Project._value, 'You need to fund with ');

    Project.projectState = ProjectState.funded;
  }


  function approveProject() public view onlyCreator {
    Project memory p;
    require(msg.sender == creator);
    require(!p._approval);
    p._approval = true;
  }

  function releaseFunds(address payable _cooperatorAddress)
    public
    payable
    onlyCreator
    {
        require(Project.projectState == ProjectState.funded, 'You have not funded this project yet. There are no funds to release.');
        require(Project._value <= address(this).balance, 'Trying to release more money than the contract has.');
        require(_cooperatorAddress == Project._cooperator);
        _cooperatorAddress.transfer(Project._value);
    }

   function revertFunds(address payable _creatorAddress)
     public
     payable
     onlyOwner
    {
        require(Project.projectState == ProjectState.funded, 'You have not funded this project yet. There are no funds to send back.');
        require(Project._value <= address(this).balance, 'Trying to release more money than the contract has.');
        require(_creatorAddress == Project._creator);
        _creatorAddress.transfer(Project._value);
    }


  function finalizeProject() public view onlyCreator {
    require(Project._approval == true);
    Project.projectState = ProjectState.finalized;
  }

}

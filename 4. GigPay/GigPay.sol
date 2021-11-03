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
    bool _hascooperator;
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
    Project storage project = activeProject;

    require(!project._hascooperator, 'There is a cooperator already.');
    require(cooperatorAddress != creator, 'You cannot set yourself as cooperator.');
    project._cooperator = cooperatorAddress;
    cooperator = project._cooperator;
    project._hascooperator = true;
  }

  function acceptProject()
      public
      view
      onlyCooperator
  {
    Project storage project = activeProject;

      require(project._cooperator == cooperator);
      project.projectState = ProjectState.accepted;
  }

  function fundProject()
    public
    payable
    onlyCreator
  {
    Project storage project = activeProject;

    require(project.projectState == ProjectState.accepted);
    require(project._value != 0);
    require(msg.value == project._value, 'You need to fund with ');

    project.projectState = ProjectState.funded;
  }


  function approveProject() public view onlyCreator {
    Project storage project = activeProject;

    require(msg.sender == creator);
    require(!project._approval);
    p._approval = true;
  }

  function releaseFunds(address payable _cooperatorAddress)
    public
    payable
    onlyCreator
    {

      Project storage project = activeProject;

        require(project.projectState == ProjectState.funded, 'You have not funded this project yet. There are no funds to release.');
        require(project._value <= address(this).balance, 'Trying to release more money than the contract has.');
        require(_cooperatorAddress == project._cooperator);
        _cooperatorAddress.transfer(project._value);
    }

   function revertFunds(address payable _creatorAddress)
     public
     payable
     onlyOwner
    {
      Project storage project = activeProject;

        require(project.projectState == ProjectState.funded, 'You have not funded this project yet. There are no funds to send back.');
        require(project._value <= address(this).balance, 'Trying to release more money than the contract has.');
        require(_creatorAddress == project._creator);
        _creatorAddress.transfer(project._value);
    }


  function finalizeProject() public view onlyCreator {
    Project storage project = activeProject;

    require(project._approval == true);
    project.projectState = ProjectState.finalized;
  }

}

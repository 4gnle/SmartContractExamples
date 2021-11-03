//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract GigPay {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  enum ProjectState {created, funded, accepted, finalized}

  struct Project {
    uint256 _value;
    address _creator;
    bool _hascreator;
    address payable _cooperator;
    bool _hascooperator;
    bool _approval;
    ProjectState projectState;
  }

  Project[1] public activeProject;

  modifier onlyCreator() {
      Project storage project = activeProject[0];


      require(msg.sender == project._creator);
      _;
  }

  modifier onlyCooperator() {
    Project storage project = activeProject[0];
      require(msg.sender == project._cooperator);
      _;
  }

    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  function setCreator() public {
    Project storage project = activeProject[0];
    require(!project._hascreator);
    project._creator = msg.sender;
    project._hascreator = true;
  }

function returnCreator() public view returns (address){
    Project storage project = activeProject[0];
    return project._creator;
  }

  function createProject(uint256 value) public onlyCreator {
    Project storage project = activeProject[0];

    project._value = value;
    project._creator = msg.sender;
    project.projectState = ProjectState.created;
  }

  function pickCooperator(address payable cooperatorAddress) public onlyCreator{
    Project storage project = activeProject[0];

    require(!project._hascooperator, 'There is a cooperator already.');
    require(cooperatorAddress != project._creator, 'You cannot set yourself as cooperator.');
    project._cooperator = cooperatorAddress;
    project._hascooperator = true;
  }

  function acceptProject()
      public
      onlyCooperator
  {
    Project storage project = activeProject[0];
    project.projectState = ProjectState.accepted;
  }

    function declineProject() public onlyCooperator {
    Project storage project = activeProject[0];

    require(project._hascooperator, 'There is no cooperator for this project');
    delete(project._cooperator);
    project._hascooperator = false;
  }

  function fundProject()
    public
    payable
    onlyCreator
  {
    Project storage project = activeProject[0];

    require(project.projectState == ProjectState.accepted);
    require(project._value != 0);
    require(msg.value == project._value, 'You need to fund with ');

    project.projectState = ProjectState.funded;
  }


  function approveProject() public onlyCreator {
    Project storage project = activeProject[0];
    require(!project._approval);
    project._approval = true;
  }

  function releaseFunds(address payable _cooperatorAddress)
    public
    payable
    onlyCreator
    {

      Project storage project = activeProject[0];

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
      Project storage project = activeProject[0];

        require(project.projectState == ProjectState.funded, 'You have not funded this project yet. There are no funds to send back.');
        require(project._value <= address(this).balance, 'Trying to release more money than the contract has.');
        require(_creatorAddress == project._creator);
        _creatorAddress.transfer(project._value);
    }


  function finalizeProject() public onlyCreator {
    Project storage project = activeProject[0];

    require(project._approval == true);
    project.projectState = ProjectState.finalized;
  }

}

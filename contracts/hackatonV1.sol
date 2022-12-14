// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract hackatonFactory{
    hackaton[] public hackatons;

    function createHackaton(string memory name_, string memory description_, uint participationLimit_, uint judgeLimit_, uint durationDays_)external{
        hackaton newHackaton = new hackaton(name_, description_, participationLimit_, judgeLimit_, durationDays_);
        hackatons.push(newHackaton);
    }

}

contract hackaton{
    address owner;
    
    string _name;
    string _description;
    uint _participationLimit;
    uint _judgeLimit;
    uint _durationDays;

    struct judge{
        address owner;
        string name;
        string description;
        bool approve;
    }

    struct team{
        uint id;
        address[] participants;
        string[] names;
        string description;
        bool approve;
        uint votes;
    }
    uint idCont = 0;
    address[] teamsAddress;

    mapping(address => judge) judges;
    mapping(address => team) teams;

    mapping(address => bool) judgeVoteControl;

    modifier onlyOwner(){
        require(msg.sender == owner, "Youre not owner");
        _;
    }

    modifier isJudge(){
        require(judges[msg.sender].approve, "Youre not judge");
        _;
    }

    constructor(string memory name_, string memory description_, uint participationLimit_, uint judgeLimit_, uint durationDays_){
        owner = tx.origin;

        _name = name_;
        _description = description_;
        _participationLimit = participationLimit_;
        _judgeLimit = judgeLimit_;
        _durationDays = durationDays_ * 1 days;
    }

    function newJudge(address owner_, string memory name_, string memory description_, bool approve_) external onlyOwner(){
        judges[owner_] = judge(owner_, name_, description_, approve_);
    }

    function newTeam(address owner_, address[] memory participants_, string[] memory names_, string memory description_, bool approve_) external onlyOwner(){
        idCont += 1;
        teams[owner_] = team(idCont, participants_, names_, description_, approve_, 0);
        teamsAddress.push(owner_);       
    }

    function totalTeams()public view returns(uint){
        return idCont;
    }

    function vote(address team_) external isJudge(){
        require(!judgeVoteControl[msg.sender]);
        judgeVoteControl[msg.sender] = true;
        teams[team_].votes += 1;
    }

    function setWin()external view onlyOwner() returns(address){
        address winner;
        winner = teamsAddress[0];
        for(uint i = 0; i < teamsAddress.length; i++){
            if(teamsAddress[i] > winner){
                winner = teamsAddress[i];
            }
        }
        return winner;
    }
}

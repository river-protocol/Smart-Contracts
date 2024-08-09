//SPDX-License-Identifier:MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

contract River is Ownable{
    struct Proposal {
        string projectName;
        string description;
        uint256 amountRequested;
        uint64 submittedTime;
        bytes32 proposalHash;
        book isApproved;
        uint256 yesVotes;
        uint256 noVotes;
    }
    struct Milestone{
        bytes32 projectId;
        bytes32 milestoneId;
        uint256 amount;
        bool isCompleted;
    }
    uint256 public constant VOTING_PERIOD = 1 weeks;
    uint256 public constant APPROVAL_PERCENT =45;
mapping(Address => address) public delegations;
    constructor() Ownable(msg.sender)
    {

    }
    function submitProposal(string memory _projectName,string memory _description,uint256 _amountRequested) external{
        bytes32 proposalId = keccak256(abi.encodePacked(_projectName,msg.sender, block.timestamp));

    }
    function vote(bytes32 _proposalId, bool _inFavor) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.submittedTime +VOTING_PERIOD ,"voting period is over");
        
        address voter = delegations[msg.sender] != address(0) ? delegations[msg.sender] : msg.sender;
   if(_inFavor){
    proposal.yesVotes++;
   }
   else{
    proposal.noVotes++;
   }
   if (block.timestamp >= proposal.submittedTime + VOTINGPERIOD)
   {
    finalize(_proposalId);
   }
    }
    function delegate(address _to) external {
        require(_to != msg.sender, "you cannot delegate to yourselves");
    }
    //register schema
    //resolver submit proposal

    //vote
    //submit proposal
    //create attestation
    //release funds
    //releasefunds resolver

}

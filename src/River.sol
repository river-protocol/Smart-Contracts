//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

contract River is Ownable{
    struct Proposal {
        address proposer;
        string description;
        bool isApproved;
        uint256 totalAmountGranted;
        uint256 currentMilestone;
        bool completed;
        string coverImage;
    }
    
   
    uint256 public constant VOTING_PERIOD = 1 weeks;
    uint256 public constant APPROVAL_PERCENT =45;
    mapping(address => address[]) private delegations;
    mapping(bytes32 => Proposal) public proposals;
    mapping(address => address) public delegatees;

    event ProposalCreated(bytes32 indexed proposalHash,address proposer,_projectName);


    constructor() Ownable(msg.sender)
    {

    }
    function CreateProposal(string memory _description,uint256 _amountRequested, string memory coverimage) external{
        bytes32 proposalId = keccak256(abi.encodePacked(_projectName,msg.sender, block.timestamp));
        proposals[proposalId] = Proposal({
            address: msg.sender;
            description: _description,
            amountRequested: _amountRequested,
            submittedTime: block.timestamp,
            proposalHash: proposalId,
            isApproved: false,
            currentMilestone:0.
            totalAmountGranted: 0,
            yesVotes: 0,
            noVotes: 0,
            coverImage: coverimage
        }); 
        emit ProposalCreated(proposalId,msg.sender,_projectName);
    
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
    proposal.isApproved = (proposal.forVotes / (proposal.forVotes + proposal.againstVotes)) *100 > 45;
        proposals[_proposalId] = proposal;

   if (block.timestamp >= proposal.submittedTime + VOTINGPERIOD)
   {
    finalize(_proposalId);
   }
    }


    function delegate(address _to) external {
        require(_to != msg.sender, "you cannot delegate to yourselves");
    }



}

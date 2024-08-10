//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

contract River is Ownable{
    enum ProposalStatus {
        Created,
        Approved,
        Milestone,
        Revoked,
        Completed
    }
    struct Proposal {
        address proposer;
        uint256 id;
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        ProposalStatus status;
        uint256 currentMilestone;
        uint256 totalAmountGranted;
        string coverImage;
        mapping(address => Vote) votes;
    }
    struct Vote {
        bool hasVoted;
        bool support;
        uint256 weight;
    }
    
    uint256 public proposalCount;
    uint256 public constant VOTING_PERIOD = 1 weeks;
    uint256 public constant VOTE_COOLDOWN_PERIOD = 2 weeks;
    uint256 public constant APPROVAL_PERCENT = 65;
    uint256 public constant MIN_VOTES = 500;
    uint256 public constant FUNDING_THRESHOLD = 40;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => address) public delegations;
    mapping(address => address) public delegatees;

    constructor() Ownable(msg.sender)
    {

    }
    function createProposal(string memory _description, string memory coverimage) external{
        id = proposalCount++;
        proposals[id] = Proposal({
            proposer: msg.sender,
            description: _description,
            yesVotes: 0,
            noVotes: 0,
            status: ProposalStatus.Created,
            currentMilestone: 0,
            totalAmountGranted: 0,
            coverImage: coverimage
        }); 
       // emit ProposalCreated(proposalCount,msg.sender,_description);
    }
    function vote(uint256 id, bool _inFavor) external {
        require(id <= proposalCount && id > 0,"Invalid proposal Id");
        Proposal storage proposal = proposals[id];
        require(proposal.status != ProposalStatus.Completed, "Voting has ended");
        
        if(_inFavor){
             proposal.yesVotes++;
            }
        else{
         proposal.noVotes++;
            }
    }
    function updatestatus(uint256 id) public {
        Proposal storage proposal = proposals[id];
        uint256 totalVotes = proposal.yesVotes + proposal.noVotes;
        
        if(totalVotes >= MIN_VOTES) {
            uint256 yesPercentage = (proposal.yesVotes * 100) /totalVotes;
            if(ProposalStatus.Created)
            {
                if (yesPercentage >= APPROVAL_PERCENT && proposal.status == ProposalStatus.Created)
                {
                proposal.status = ProposalStatus.Approved;
                }
                else 
                {
                proposal.status = ProposalStatus.Revoked;
                }
            }

            else if (proposal.status == ProposalStatus.Approved || proposal.status == ProposalStatus.Milestoned)
            {
                if(yesPercentage > FUNDING_THRESHOLD)
                {
                proposal.status = ProposalStatus.MileStoned;
                }
                else
                {
                proposal.status = ProposalStatus.Revoked;
                }
            }


        }
        proposal.lastVoteCheck = block.timestamp;

    }

    function submitMilestone(uint256 id, string memory proposalhash) external {
        Proposal storage proposal = proposals[id];
        require(msg.sender == proposal.proposer, "only proposer can submit");
        require(proposal.status ==ProposalStatus.Approved || ProposalStatus.MileStoned,"Proposal not in correct status");
        require(proposal.currentMileStone < 5, "All milestones completed");
        proposal.currentMileStone++;
        if (proposal.status == ProposalStatus.Approved) {
            //do i implement eas
            proposal.status = ProposalStatus.Milestoned;
        }
        else if (proposal.currentMilestone == 5) {
            proposal.status = ProjectStatus.Completed;
        }
        //emit event with proposal hash for frontend


    }

     
    function checkUpKeep()
    function performUpKeep()


     /*function delegate(address _to) external {
        require(_to != msg.sender, "you cannot delegate to yourselves");
        if(delegations[msg.sender] != address(0)) {
        }
    } */



}

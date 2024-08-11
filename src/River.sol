//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

contract River is Ownable{
    enum ProposalStatus {
        Created,
        Approved,
        Milestoned,
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
        uint256 lastVoteCheck;
        mapping(address => Vote) votes;
    }
    struct Vote {
        bool hasVoted;
        bool support;
        uint256 weight;
        uint256 lastVoteTime;
    }
    
    uint256 public proposalCount;
    uint256 public constant VOTING_PERIOD = 1 weeks;
    uint256 public constant VOTE_COOLDOWN_PERIOD = 2 weeks;
    uint256 public constant APPROVAL_PERCENT = 65;
    uint256 public constant MIN_VOTES = 500;
    uint256 public constant FUNDING_THRESHOLD = 40;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => address) public delegations;
    mapping(address => uint256) public delegationCount;

    event SubmittedMilestone(uint256 indexed id, string indexed ipfshash);
    event ProposalCreated(uint256 indexed id,address indexed proposer,string indexed _description);
    event Delegated(address indexed from, address indexed to);
    event Undelegated(address indexed from, address indexed to);

    constructor() Ownable(msg.sender)
    {

    }
    function createProposal(string memory _description, string memory coverimage) external{
        uint256 id = proposalCount++;
        Proposal storage proposal = proposals[id];
            proposal.proposer = msg.sender;
            proposal.description = _description;
            proposal.yesVotes = 0;
            proposal.noVotes = 0;
            proposal.status = ProposalStatus.Created;
            proposal.currentMilestone = 0;
            proposal.totalAmountGranted = 0;
            proposal.lastVoteCheck = block.timestamp;
            proposal.coverImage = coverimage;
            emit ProposalCreated(id,msg.sender,_description);
        }
     
    

    function delegate(address _to) external
    {
    require(_to != msg.sender, "Cannot delegate to self");
    require(delegations[msg.sender] != _to, "Already delegated to this address");

    address current = _to;
    while (delegations[current] != address(0)) {
    require(delegations[current] != msg.sender, "Found loop in delegation");
    current = delegations[current];
    }

    if (delegations[msg.sender] != address(0)) {
    delegationCount[delegations[msg.sender]]--;
    }

    delegations[msg.sender] = _to;
    delegationCount[_to]++;

    emit Delegated(msg.sender, _to);
    }

    function vote(uint256 id, bool _inFavor) external {
        require(id <= proposalCount && id > 0,"Invalid proposal Id");
        Proposal storage proposal = proposals[id];
        require(proposal.status != ProposalStatus.Completed, "Voting has ended");
        address voter = msg.sender;
        uint256 weight = 1+ delegationCount[voter];
        if(proposal.votes[voter].hasVoted){
            require(block.timestamp>= proposal.votes[voter].lastVoteTime + VOTE_COOLDOWN_PERIOD, "VoteCooldown hasn't passed");
        if(proposal.votes[voter].support){
            proposal.yesVotes -= proposal.votes[voter].weight;
        }
        else
        {
            proposal.noVotes -= proposal.votes[voter].weight;
        }
        }
        if(_inFavor){
             proposal.yesVotes += weight;
            }
        else{
         proposal.noVotes += weight;
            }
            proposal.votes[voter] = Vote({
                hasVoted: true,
                support: _inFavor,
                weight: weight,
                lastVoteTime:block.timestamp
            });
    }

    function updatestatus(uint256 id) public {
        Proposal storage proposal = proposals[id];
        uint256 totalVotes = proposal.yesVotes + proposal.noVotes;
        require(block.timestamp > proposal.lastVoteCheck + VOTING_PERIOD, "Voting period has not ended yet");
        if(totalVotes >= MIN_VOTES) {
            uint256 yesPercentage = (proposal.yesVotes * 100) /totalVotes;
            if(proposal.status == ProposalStatus.Created)
            {
                if (yesPercentage >= APPROVAL_PERCENT)
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
                proposal.status = ProposalStatus.Milestoned;
                }
                
            }
            else
            {
                proposal.status = ProposalStatus.Revoked;
            }


        }
        proposal.lastVoteCheck = block.timestamp;

    }

    function submitMilestone(uint256 id, string memory ipfshash) external {
        Proposal storage proposal = proposals[id];
        require(msg.sender == proposal.proposer, "only proposer can submit");
        require(proposal.status == ProposalStatus.Approved || proposal.status == ProposalStatus.Milestoned,"Proposal not in correct status");
        require(proposal.currentMilestone < 5, "All milestones completed");
        proposal.currentMilestone++;
        if (proposal.status == ProposalStatus.Approved) {
            proposal.status = ProposalStatus.Milestoned;
            //code to start stream
        }
        else if (proposal.currentMilestone == 5) {
            proposal.status = ProposalStatus.Completed;
            //code to end stream
        }
        emit SubmittedMilestone(id,ipfshash);


    }
    function undelegate() external {
    require(delegations[msg.sender] != address(0), "Not currently delegating");
    address delegatee = delegations[msg.sender];
    delegationCount[delegatee]--;
    delegations[msg.sender] = address(0);
    emit Undelegated(msg.sender, delegatee);
    }

    function finalizeProposal(uint256 id) public {
    updatestatus(id);
    }


    function getProposalVotes(uint256 id) public view returns (uint256 yesVotes, uint256 noVotes) {
    Proposal storage proposal = proposals[id];
    return (proposal.yesVotes, proposal.noVotes);
    }

    function getProposalStatus(uint256 id) public view returns (ProposalStatus) {
    return proposals[id].status;
    }

    


     
    



}

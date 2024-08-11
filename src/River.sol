//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

contract River is Ownable{
    enum ProposalStatus {
        Created,
        Approved,
        Milestoned,
        Revoked,
        Completed,
        Settled
    }
    struct Proposal {
        address proposer;
        uint256 id;
        string description;
        uint256 amountRequested;
        uint256 yesVotes;
        uint256 noVotes;
        ProposalStatus status;
        uint256 currentMilestone;
        uint256 totalAmountGranted;
        string coverImage;
        uint256 lastVoteCheck;
        mapping(address => Vote) votes;
    }
     struct ProposalView {
        address proposer;
        uint256 id;
        string description;
        uint256 amountRequested;
        uint256 yesVotes;
        uint256 noVotes;
        ProposalStatus status;
        uint256 currentMilestone;
        uint256 totalAmountGranted;
        string coverImage;
        uint256 lastVoteCheck;
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
    address public constant L1_CROSS_DOMAIN_MESSENGER_PROXY = 0xfDbc7c5af17a71A7F89c333339E139f8a92E99CF;

    modifier validDelegate(address _to) {
        bool allowed = false;
        for (uint i = 0; i < delegates.length; i++) {
            if (delegates[i] == _to) {
                allowed = true;
            }
        }
        require(allowed, "Delegate is not registered");
        _;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => address) public delegations;
    mapping(address => uint256) public delegationCount;

    address[] public delegates;

    event SubmittedMilestone(uint256 indexed id, string indexed ipfshash);
    event ProposalCreated(uint256 indexed id,address indexed proposer,string indexed _description);
    event Delegated(address indexed from, address indexed to);
    event Undelegated(address indexed from, address indexed to);

    constructor() Ownable(msg.sender)
    {

    }
    function createProposal(string memory _description, string memory coverimage,uint256 amountRequested) external{
        uint256 id = ++proposalCount;
        Proposal storage proposal = proposals[id];
            proposal.proposer = msg.sender;
            proposal.description = _description;
            proposal.yesVotes = 0;
            proposal.noVotes = 0;
            proposal.status = ProposalStatus.Created;
            proposal.amountRequested = amountRequested;
            proposal.currentMilestone = 0;
            proposal.totalAmountGranted = 0;
            proposal.lastVoteCheck = block.timestamp;
            proposal.coverImage = coverimage;
            emit ProposalCreated(id,msg.sender,_description);
        }
     
    

    function delegate(address _to) external validDelegate(_to)
    {
    require(_to != msg.sender, "Cannot delegate to self");
    require(delegations[msg.sender] != _to, "you have already delegated to this address");
    address current = _to;
    while (delegations[current] != address(0)) {
    require(delegations[current] != msg.sender, "Found a loop in delegation");
    current = delegations[current];
    }
    if (delegations[msg.sender] != address(0)) {
    delegationCount[delegations[msg.sender]]--;
    }

    delegations[msg.sender] = _to;
    delegationCount[_to]++;

    emit Delegated(msg.sender, _to);
    }
     /**
        * @dev This function allows a user to vote on a proposal. 
        * The voting is weighted by the number of delegates from the voter's address.
        * If the voter has already voted, it requires that their last vote be at least one week old before they can vote again.
        * It checks if the proposal id exists and if the voting period hasn't ended yet. 
        * The function then adds or subtracts from the yesVotes or noVotes based on whether _inFavor is true or false, respectively.
        * @param id The ID of the proposal to vote on.
        * @param _inFavor True if the voter supports the proposal, False otherwise.
    */ 

    function vote(uint256 id, bool _inFavor) external {
        require(id <= proposalCount && id > 0,"Invalid proposal Id");
        Proposal storage proposal = proposals[id];
        require(msg.sender != proposal.proposer,"You cant vote on your own proposal");
        require(proposal.status != ProposalStatus.Completed, "Voting has ended");
        if(isDelegating(msg.sender) != address(0)) {
            undelegate();
        }
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
        require(msg.sender == isDelegating(proposal.proposer), "delegate before submitting");
        
        if (proposal.status == ProposalStatus.Approved) {
            
            proposal.status = ProposalStatus.Milestoned;
            proposal.currentMilestone++;
        }
        else if (proposal.currentMilestone == 5) {
            proposal.status = ProposalStatus.Completed;
        }
        emit SubmittedMilestone(id,ipfshash);


    }
    function undelegate() public {
    require(delegations[msg.sender] != address(0), "Not currently delegating");
    address delegatee = delegations[msg.sender];
    delegationCount[delegatee]--;
    delegations[msg.sender] = address(0);
    emit Undelegated(msg.sender, delegatee);
    }

    function finalizeProposal(uint256 id) public {
    updatestatus(id);
    }
    function grant() external {
        require(msg.sender == L1_CROSS_DOMAIN_MESSENGER_PROXY, "Unauthorized");
        for (uint256 i = 1; i <= proposalCount; i++) {
            Proposal storage proposal = proposals[i];
            updatestatus(i);
            if ((proposal.status == ProposalStatus.Milestoned || proposal.status == ProposalStatus.Completed)) {
                proposal.totalAmountGranted += proposal.amountRequested / 5;
            }
            if (proposal.totalAmountGranted >= proposal.amountRequested) {
                proposal.status = ProposalStatus.Settled;
            }
        }
    }
    function withdraw(uint256 id) public {
        Proposal storage proposal = proposals[id];
        require(
            proposal.status == ProposalStatus.Milestoned,
            "Proposal not completed"
        );
        require(
            proposal.proposer == msg.sender,
            "Only proposer can withdraw"
        );
        payable(msg.sender).transfer(proposal.totalAmountGranted);
    }

    function allocate(uint256 id) public payable {
        Proposal storage proposal = proposals[id];
        require(
            proposal.status != ProposalStatus.Settled || proposal.status != ProposalStatus.Revoked,
            "Not valid"
        );
        require(msg.value >= proposal.amountRequested, "Insufficient funds");
    }


    function getProposalVotes(uint256 id) public view returns (uint256 yesVotes, uint256 noVotes) {
    Proposal storage proposal = proposals[id];
    return (proposal.yesVotes, proposal.noVotes);
    }

    function getProposalStatus(uint256 id) public view returns (ProposalStatus) {
    return proposals[id].status;
    }

    function isDelegating(address _user) public view returns (address) {
        return delegations[_user];
    }

    function setDelegates(address[] memory _delegates) public onlyOwner {
        delegates = _delegates;
    }

    function getProposals() public view returns (ProposalView[] memory) {
        ProposalView[] memory _proposals = new ProposalView[](proposalCount);
        for (uint256 i = 0; i < proposalCount; i++) {
            Proposal storage proposal = proposals[i + 1];
            _proposals[i] = ProposalView(
                proposal.proposer,
                proposal.id,
                proposal.description,
                proposal.amountRequested,
                proposal.yesVotes,
                proposal.noVotes,
                proposal.status,
                proposal.currentMilestone,
                proposal.totalAmountGranted,
                proposal.coverImage,
                proposal.lastVoteCheck
            );
        }
        return _proposals;
    }

}

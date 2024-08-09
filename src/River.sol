//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

contract River is Ownable{
    struct Proposal {
        string projectName;
        uint256 amountRequested;
        string description;
    }
    struct Milestone{
        bytes32 projectId;
        bytes32 milestoneId;
        uint256 amount;
        bool isCompleted;
    }
    //register schema
    //create attestation
    //resolver submit proposal

    //vote
    //submit proposal
    //create attestation
    //release funds
    //releasefunds resolver

}

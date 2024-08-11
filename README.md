One of the comments on the Optimism's mission request was a huge inspiration for us.
https://gov.optimism.io/t/mission-request-grants-claiming-tool/8513/2

## Optimism

### Fork it

Forked and modified the OP Stack to deployed an L2 -River Protocol. A token streaming L2 to address the grants/funds distribution with improved gas efficiency.

## MetalL2

### Passkeys Integration:

Integrated Turnkey by connecting the passkey signer to metal, for improved onboarding.
https://testnet.explorer.metall2.com/address/0x674cbDB19cdf3C1f23fAf0204B584Fc9e0cFeb3E

### Most interesting smart contract deployed on Metal L2

#### Contract:

https://testnet.explorer.metall2.com/address/0x674cbDB19cdf3C1f23fAf0204B584Fc9e0cFeb3E

## Blockscout

⭐️ Use Blockscout Block Explorer!
River Protocol uses blockscout for displaying user transactions within the app.

#### Details:

0x674cbDB19cdf3C1f23fAf0204B584Fc9e0cFeb3E
RPC: http://34.170.15.42:9545
Verified Smart Contract on Blockscout : https://testnet.explorer.metall2.com/address/0x674cbDB19cdf3C1f23fAf0204B584Fc9e0cFeb3E
Blockscout in Presentation:https://ethglobal.com/showcase/undefined-u02mk
Dapp submitted to Dappscout marketplace


---
## Project Description
We build a grant distribution for DAOs with efficient token streaming on a rollup exclusively built for this. River Protocol is a token streaming dapp customized from OP stack. 

One of the comments on the Optimism's mission request was a huge inspiration for us.
https://gov.optimism.io/t/mission-request-grants-claiming-tool/8513/2

 It allows community members to create, vote on, and manage proposals in a transparent and decentralized manner. The system incorporates features such as delegated voting, milestone-based project progression, and a dynamic proposal status system.
Key Features:
Exclusive Rollup : All funds are handled on the River rollup we built. The contracts are on metal are used to interact with 
Better UX : TurnKey to implement Passkeys integration for metal.
Proposal Creation: Any user can create a proposal, which includes a description and a cover image.
Delegated Voting: Users can delegate their voting power to other addresses, increasing the influence of trusted community members.
Weighted Voting: Votes are weighted based on the number of delegations a voter has received, allowing for more nuanced decision-making.
Time-bound Voting: Each proposal has a specific voting period, after which the results are finalized.
Vote Cooldown: To prevent rapid vote changes, there's a cooldown period between votes from the same address.
Multiple Proposal Statuses: Proposals can be in various states (Created, Approved, Milestoned, Revoked, Completed) based on community votes and milestone completions.
Milestone Submission: Approved proposals can submit milestones, allowing for phased project development and funding.
Automatic Status Updates: The system can automatically update proposal statuses based on voting outcomes and milestone completions.
Minimum Participation Thresholds: A minimum number of votes is required for a proposal to be considered valid.
Approval and Funding Thresholds: Different percentage thresholds are set for proposal approval and ongoing funding.

The River platform aims to provide a robust framework for decentralized decision-making and project funding. It balances the need for community participation with mechanisms to ensure thoughtful and considered voting. The milestone-based approach allows for ongoing community oversight of approved projects, ensuring accountability and the ability to revoke support if necessary.
This system could be particularly useful for managing community funds, making collective decisions on project directions, or governing any decentralized organization where transparent, community-driven decision-making is crucial.

How it's made:
We forked and modified the Optimism to support gas optimized token streaming. The contract was deployed on Metal since the banking layer was efficient in distribution. The token was distribution logic was written in the metal which would trigger a distribution from River Protocol (modified OP). The stream is also supported by a bridge between metal and River.  Turnkey was implemented for passkyes based signin.
We learnt a lot about rollups and token bridges. Spending a lot of time on research within the community felt so worth it and gave a satisfaction of solving a real problem they face.
We forked and played around with the OP stack, until we could execute a token stream with efficient gas.

All repositories within the org are part of the project:
https://github.com/river-protocol


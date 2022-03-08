// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ballot {
    // This declares a new complex type which will be used for variable later.
    // It will represent a single vote.
    struct Voter {
        uint weight; // Weight is accumulate by delegation.
        bool voted; // If true, that person already voted.
        address delegate; // Person delegate to.
        uint vote; // Index of vote proposal.
    }

    // This is a type for a single proposal
    struct Proposal { // Like interfaces TypeScript
        bytes32 name; // Short name up to 32 bytes.
        uint voteCount; // Number of acumulated votes.
    }

    address public chairperson;

    // This declares a state variable that stores a `Voter` struct for each possible address.
    mapping (address => Voter) public voters;

    // A dynamically-sized array of `Proposal` struct.
    Proposal[] public proposals; // Array of Proposal structs.

    // Create a new ballot to chose one of the `proposalNames`
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // For each of the provided proposal names, create a new proposal object and add it to the end of the array
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary Proposal object and 
            // proposals.push(...) appends it to the end of proposals
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount:0
            }));
        }
    }

    // Give `Voter` the right to vote on this ballot.
    // May only be called by `Chairperson`.
    function giveRightToVote(address voter) external {
        // If the frist argument of `Require` evaluates to 'false', execution terminates and all,
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // Its often a good ideia to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == chairperson, "Only chairperson can give right to vote");
        require(!voters[voter].voted, "The voter already voted");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    // Delegate your vote to the voter 'to'.
    function delegate(address to) external {
        // Assigns reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted");

        require(to != msg.sender, "Self-delegation is disallowed");

        // Foward the delegation as long as 'to' also delegated.
        
        // In general, such loops are very dangerous  because if they run too long, they mighty,
        // need more gas than is avaliable in a block.

        // In this case, the delegation will not be executed but in other situations, such loops might cause a contract to get "stuck" completly.

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed
            require(to != msg.sender, "Found loop in delegation");
        } 

        // Since "sender" is a reference, this modifiers 'voters[msg.sender].voted
        Voter storage delegate_ = voters[to];

        require(delegate_.weight >= 1);
        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            // If the delegate already voted, directly add to the number of votes.
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet, add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted");

        sender.voted = true;
        sender.vote = proposal;

        // If 'proposal'  is out of the range of the array, this will throw automatically and revert all changes.
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;

        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }


    // Calls winningProposal() function to get the index of the winner contained
    // of the winner contained in the proposals array and then returns the name of the winner.
    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}
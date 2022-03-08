// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

contract Coin {

    // The keyword public makes variable accessible from others contracts
    // This line declares a state variable of type address.
    // The type address is a 160-bit value that does not allow any arithmetic operations.
    // Its suitable to store address of contracts.
    address public minter; // The minter keyword generate a function like: 
    // function minter() external view returns (address) { return minter; }
    // The keyword public automatically generates a function that allows you to access the current value of the state variable from outside of the contract.    
    // Without this word contracts have no way to access the variable. The

    // Also creates a public variable but its more complex datatype.
    // The mapping type maps addresses to unsigned integers.
    mapping (address => uint) public balances;

    // Event allow clients to react specific contract changes you declare
    event Sent(address from, address to, uint amount);

    // Contructor code is only run when the contract is created

    constructor() {
        minter = msg.sender;
    }

    // Sends an amount of newly created coints to an address
    // Can only be called by the contract creator
    function mint(address reciver, uint amount) public {
        require(msg.sender == minter);
        balances[reciver] += amount;
    }

    // Errors allow you to provide information about why an operation failed. 
    // They are returned to the caller of the function.
    error InsuficientBalance(uint requested, uint avaliable);

    // Sends an amount of existing coins from any caller to an address
    function send(address reciver, uint amount) public {
        if (amount > balances[msg.sender])
        revert InsuficientBalance({
            requested: amount,
            avaliable: balances[msg.sender]
        });

        balances[msg.sender] -= amount;
        balances[reciver] += amount;
        emit Sent(msg.sender, reciver, amount);
    }
}
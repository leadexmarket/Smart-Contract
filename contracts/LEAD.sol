pragma solidity ^0.4.23;

import './MintableToken.sol';
import './ownership/Claimable.sol';


contract LEAD is MintableToken, Claimable {
    string public constant name = "LEADEX"; 
    string public constant symbol = "LEAD";
    uint public constant decimals = 8;
}

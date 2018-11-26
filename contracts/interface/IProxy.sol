pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract IProxy is Ownable{
    uint256 version;
    address targetAddress;
}
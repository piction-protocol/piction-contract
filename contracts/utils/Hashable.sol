pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "contracts/utils/ValidValue.sol";

contract Hashable is Ownable, ValidValue {
    string hash;
    uint256 version;

    function setHash(string _hash) public onlyOwner validString(_hash) {
        hash = _hash;

        emit ChangedHash(msg.sender, hash);
    }

    function getHash() public view returns(string hash_) {
        return hash;
    }

    function isEqual(string _compareHash) public view returns (bool isEqual_) {
        return keccak256(hash) == keccak256(_compareHash);
    }

    event ChangedHash(address indexed _user, string _hash);
}
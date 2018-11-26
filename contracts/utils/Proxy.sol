pragma solidity ^0.4.24;

import "contracts/interface/IProxy.sol";

contract Proxy is IProxy {

    function setTargetAddress(address _address) public onlyOwner {
        require(_address != address(0));
        targetAddress = _address;
        version++;
    }

    function getTargetAddress() public view returns(address targetAddresss_) {
        return targetAddress;
    }

    function getVersion() public view returns(uint256 version_) {
        return version;
    }

    function () public {
        address contractAddr = targetAddress;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, contractAddr, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
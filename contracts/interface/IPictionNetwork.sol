pragma solidity ^0.4.24;

contract IPictionNetwork {
    function validUser(address _user) external view returns(bool isValid_);
    function validContents(address _contents) external view returns(bool isValid_);
    function getCdRate() external view returns (uint256 rate_);
    function getPxlAddress() external view returns (address pxl_);
    function getPixelDistributor() external view returns (address distributor_);
    function getContentsDistributors() external view returns (address[] memory contentsDistributor_);
    function isContentsDistributor(address _cd) external view returns (bool isContentsDistributor_);
    function getCouncils() external view returns (address[] memory councils_);
    function isCouncil(address _council) external view returns (bool isCouncil_);
}
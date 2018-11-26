pragma solidity ^0.4.24;

contract IPictionNetwork {
    function setPxlAddress(address _pxl) external;
    function validUser(address _user) external view returns(bool isValid_);
    function validContents(address _contents) external view returns(bool isValid_);
    function getCdRate() external view returns (uint256 rate_);
    function getPxlAddress() external view returns (address pxl_);
    function getPixelDistributor() external view returns (address distributor_);
    function getContentsDistributors() external view returns (address[] memory contentsDistributor_);
    function isContentsDistributor(address _cd) public view returns (bool isContentsDistributor_);
    function getCouncils() external view returns (address[] memory councils_);
    function isCouncil(address _council) public view returns (bool isCouncil_);
    function addUser(address _user) external;
    function addContents(address _contents) external;
    function addContentsDistributors(address _contentsDistributor) external;
    function addCouncils(address _council) external;
    function setConctentsDistributorRate(uint256 _rate) external;
    function setPixelDistributor(address _pixelDistributor) external;
}
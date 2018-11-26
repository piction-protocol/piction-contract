pragma solidity ^0.4.24;

contract IContents {
    function getOwner() public view returns(address owner_);
    function getPrice() public view returns(uint256 price_);
    function getPublishedTo() public view returns(uint256 publishedTo_);
    function isPurchased(address _user) public view returns(bool isPurchased_);
    function setPrice(uint256 _price) external;
    function setPublishedTo(uint256 _publishedTo) external;
    function purchase(address _user, uint256 _price) external;
}
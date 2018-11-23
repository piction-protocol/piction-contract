pragma solidity ^0.4.24;

import "contracts/interface/IContents.sol";

contract IEpisode is IContents{
    function getImages() public view returns(bytes16[] images_);
    function getImage(uint256 _index) public view returns(bytes16 image_);
    function setImage(bytes16 _image, uint256 _index) public;
    function setImages(bytes16[] _images) public;
    function changeImageOrder(uint256 _oldOrder, uint256 _newOrder) public;
}
pragma solidity ^0.4.24;

import "contracts/interface/IPictionNetwork.sol";
import "contracts/interface/IEpisode.sol";

import "contracts/utils/Hashable.sol";
import "contracts/utils/TimeLib.sol";

contract Episode is Hashable, IEpisode {

    mapping (address => bool) purchasedUser;            // 구매 유저

    uint256 price;          // 판매 금액
    uint256 publishedTo;    // 공개 일자
    bytes16[] images;       // 16 byte로 생성한 image hash

    address piction;        // piction network contract 주소

    /**
     * @dev 생성자
     *
     * @param _piction piction network contract 주소
     * @param _hash episode의 정보를 사용하여 생성한 hash string
     * @param _images image file의 hash 정보
     * @param _price 판매 금액
     * @param _publishedTo 공개 시간 unix timestamp(ms)
     */
    constructor (
        address _piction,
        string _hash,
        bytes16[] _images,
        uint256 _price,
        uint256 _publishedTo
    ) 
        public
        validAddress(_piction)
    {
        require(_images.length > 0, "Episode Creation failed: Please check the image");

        setHash(_hash);

        price = _price;
        images = _images;
        publishedTo = (TimeLib.currentTime() > _publishedTo)? TimeLib.currentTime() : _publishedTo;

        piction = _piction;
        
        emit CreateEpisode(msg.sender, _hash, price, publishedTo);
    }

    /**
     * @dev 작가 주소 조회
     *
     * @return owner_ 작가 주소
     */
    function getOwner() public view returns(address owner_) {
        return owner();
    }

    /**
     * @dev episode 판매 금액 조회 
     *
     * @return price_ 판매 pixel 금액
     */
    function getPrice() public view returns(uint256 price_) {
        return price;
    }

    /**
     * @dev episode 공개 시간 조회
     *
     * @return publishedTo_ unix timestamp(ms) 형식의 공개 시간
     */
    function getPublishedTo() public view returns(uint256 publishedTo_) {
        return publishedTo;
    }

    /**
     * @dev 에피소드 전체 이미지 hash 조회
     *
     * @notice msg.sender가 구매한 유저거나 컨트랙트 오너만 조회 가능
     * @return images_ 16 bytes로 생사한 이미지 hash 배열
     */
    function getImages() public view returns(bytes16[] images_) {
        if(purchasedUser[msg.sender] || isOwner()){
            images_ = images;
        }
    }

    /**
     * @dev 에피소드 이미지 컷 hash 조회
     *
     * @notice msg.sender가 컨트랙트 오너만 조회 가능
     * @param _index 이미지 index
     * @return images_ 16 bytes로 생사한 이미지 hash
     */
    function getImage(uint256 _index) public view returns(bytes16 image_) {
        if(isOwner() && images.length >= _index){
            image_ = images[_index];
        }
    }

    /**
     * @dev 에피소드 구매여부 조회
     *
     * @param _user 조회하고자 하는 유저 지갑 주소
     * @return isPurchased_ 구매 여부
     */
    function isPurchased(address _user) public view returns(bool isPurchased_) {
        return purchasedUser[_user];
    }

    /**
     * @dev 에피소드 금액 설정
     *
     * @param _price 설정할 pxl 양
     */
    function setPrice(uint256 _price) public onlyOwner {
        emit ChangePrice(msg.sender, price, _price);

        price = _price;
    }

    /**
     * @dev 에피소드 공개 시간 설정
     *
     * @notice 변경하고자하는 시간이 현재시간보다 클때만 변경 가능
     * @param _publishedTo unix timestamp(ms) 형식의 공개 시간
     */
    function setPublishedTo(uint256 _publishedTo) public onlyOwner {
        require(TimeLib.currentTime() <= _publishedTo, "Failed to change release date: Check the release date.");

        emit ChangeReleaseDate(msg.sender, publishedTo, _publishedTo);
        publishedTo = _publishedTo;
    }

    /**
     * @dev 에피소드 이미지 컷 hash 설정
     *
     * @param _image 이미지 파일의 hash
     * @param _index 이미지 배열의 index
     */
    function setImage(bytes16 _image, uint256 _index) public onlyOwner {
        require(images.length >= _index, "Failed to change images: Check the image index");

        emit ChangeImage(msg.sender, _index, images[_index], _image);
        images[_index] = _image;
    }

    /**
     * @dev 에피소드 전체 이미지 hash 설정
     *
     * @param _images 이미지 파일의 hash 배열
     */
    function setImages(bytes16[] _images) public onlyOwner {
        require(_images.length > 0, "Failed to change images: Check the image");

        emit ChangeImages(msg.sender, images.length, _images.length);
        images = _images;
    }

    /**
     * @dev 에피소드 이미지 순서변경
     *
     * @param _oldOrder 변경될 이미지 index
     * @param _newOrder 변경하고 싶은 이미지 index
     */
    function changeImageOrder(uint256 _oldOrder, uint256 _newOrder) public onlyOwner {
        require(_oldOrder < images.length, "Out of index: check oldOrder");
        require(_newOrder < images.length, "Out of index: check newOrder");
        require(_oldOrder != _newOrder, "Failed to change image order: Check the index");

        bytes16 temp = images[_oldOrder];
        images[_oldOrder] = images[_newOrder];
        images[_newOrder] = temp;

        emit ChangeImageOrder(msg.sender, _oldOrder, _newOrder);
    }

    /**
     * @dev 에피소드 구매 유저 기록
     *
     * @notice 변경하고자하는 시간이 현재시간보다 클때만 변경 가능
     * @notice 이미 구매한 유저의 경우 revert 처리(pixel이 소모되지 않도록)
     * @notice 구매에 사용한 pxl과 구매한 에피소드에 등록된 pxl이 틀릴경우 revert 처리
     * @param _user 구매한 유저 지갑 주소
     * @param _price 구매한 pxl
     */
    function purchase(address _user, uint256 _price) external validAddress(_user) {
        require(IPictionNetwork(piction).getPixelDistributor() == msg.sender, "Purchase failed: Access denied.");
        require(!purchasedUser[_user], "Purchase failed: Already purchased.");
        require(price == _price, "Purchase failed: Check the sales price.");

        purchasedUser[_user] = true;

        emit Purchased(_user, _price);
    }

    event CreateEpisode(address indexed _user, string _hash, uint256 _price, uint256 _publishedTo);
    event Purchased(address indexed _user, uint256 _price);
    event ChangePrice(address indexed _user, uint256 _before, uint256 _after);
    event ChangeReleaseDate(address indexed _user, uint256 _before, uint256 _after);
    event ChangeImages(address indexed _user, uint256 _before, uint256 _after);
    event ChangeImage(address indexed _user, uint256 _index, bytes16 _before, bytes16 _after);
    event ChangeImageOrder(address indexed _user, uint256 _oldOrder, uint256 _newOrder);
}
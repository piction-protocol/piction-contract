pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/interface/IProxy.sol";
import "contracts/interface/IPictionNetwork.sol";

import "contracts/utils/ValidValue.sol";

contract PictionNetwork is IProxy, Ownable, IPictionNetwork, ValidValue{

    mapping(address => bool) users;         // piction network에 등록한 유저 지갑 주소
    mapping(address => bool) contents;      // piction network에 등록한 콘텐츠 컨트렉트 주소
     
    uint256 cdRate;                         // Contents Distributor 분배 비율(Bignumber)
    
    address pxl;                            // Pixel token contract 
    address distributor;                    // Pixel distributor contract(컨텐츠 판매 시 분배 기능)

    address[] councils;                     // 위원회 멤버
    address[] contentsDistributors;         // Contents Distributor 멤버 정보
    
    /**
     * @dev 생성자
     *
     * @param _pxl Pixel token contract 주소
     */
    constructor (address _pxl) public validAddress(_pxl) {
        pxl = _pxl;
    }

    /**
     * @dev 등록된 유저 여부 조회
     *
     * @param _user 유저 지갑 주소
     * @return isValid_ 등록 여부
     */
    function validUser(address _user) external view returns(bool isValid_) {
        return users[_user];
    }

    /**
     * @dev 등록된 컨텐츠 여부 조회
     *
     * @param _contents contract 주소
     * @return isValid_ 등록 여부
     */
    function validContents(address _contents) external view returns(bool isValid_) {
        return contents[_contents];
    }

    /**
     * @dev contents distributor 분배 비율 조회
     *
     * @return rate_ 비율(bignumber)
     */
    function getCdRate() external view returns (uint256 rate_) {
        return cdRate;
    }

    /**
     * @dev pixel token 주소 조회
     *
     * @return pxl_ pixel token contract 주소
     */
    function getPxlAddress() external view returns (address pxl_) {
        return pxl;
    }

    function getPixelDistributor() external view returns (address distributor_) {
        return distributor;
    }

    /**
     * @dev Contents Distributor 목록 조회
     *
     * @return contentsDistributor_ Contents Distributor 주소 배열
     */
    function getContentsDistributors() external view returns (address[] memory contentsDistributor_) {
        return contentsDistributors;
    }

    /**
     * @dev Contents Distributor 멤버 여부 조회
     *
     * @notice contents distributor 주소를 mapping 변수로 추가할지 확인 필요(멤버 수가 증가하면 처리 속도의 문제 발생)
     * @param _cd Contents Distributor 주소
     * @return isContentsDistributor_ 멤버 여부
     */
    function isContentsDistributor(address _cd) external view returns (bool isContentsDistributor_) {
        for(uint256 i = 0 ; i < contentsDistributors.length ; i++){
            if(contentsDistributors[i] == _cd) {
                isContentsDistributor_ = true;
            }
        }
    }

    /**
     * @dev 위원회 멤버 조회
     *
     * @return councils_ Council 주소 배열
     */
    function getCouncils() external view returns (address[] memory councils_) {
        return councils;
    }

    /**
     * @dev 위원회 멤버 여부 조회
     *
     * @notice 최대 인원이 21명으로 for loop로 검색해도 문제가 없을지 확인 필요
     * @param _council 지갑 주소
     * @return isCouncil_ 등록 여부
     */
    function isCouncil(address _council) external view returns (bool isCouncil_) {
        for(uint256 i = 0 ; i < councils.length ; i++){
            if(councils[i] == _council) {
                isCouncil_ = true;
            }
        }
    }

    /**
     * @dev 유저 등록
     *
     * @param _user 유저의 지갑 주소
     */
    function addUser(address _user) external onlyOwner validAddress(_user) {
        //onlyOwner를 제외하고 추가로 예외처리 필요(미확정)
        users[_user] = true;

        emit AddUser(msg.sender, _user);
    }

    /**
     * @dev contents 등록
     *
     * @param _contents contents contract 주소
     */
    function addContents(address _contents) external onlyOwner validAddress(_contents) {
        //onlyOwner를 제외하고 추가로 예외처리 필요(미확정)
        contents[_contents] = true;

        emit AddContents(msg.sender, _contents);
    }

    /**
     * @dev contents distributor 등록
     *
     * @param _contentsDistributor contents distributor로 등록할 지갑 주소
     */
    function addContentsDistributors(address _contentsDistributor) external onlyOwner validAddress(_contentsDistributor) {
        //contents distributor로 등록할수 있는 권한을 확인하는 로직 추가 필요(미확정)
        contentsDistributors.push(_contentsDistributor);

        emit AddContentsDistributor(msg.sender, _contentsDistributor, contentsDistributors.length);
    }

    /**
     * @dev council 등록
     *
     * @param _council council로 등록할 지갑 주소
     */
    function addCouncils(address _council) external onlyOwner validAddress(_council) {
        //위원회로 등록할수 있는 권한을 확인하는 로직 추가 필요(미확정)
        councils.push(_council);

        emit AddCouncils(msg.sender, _council, councils.length);
    }

    /**
     * @dev contents distributor 수수료 비율 설정
     *
     * @param _rate 비율(bignumber)
     */
    function setConctentsDistributorRate(uint256 _rate) external onlyOwner {
        cdRate = _rate;

        emit SetContentsDistributorRate(msg.sender, _rate);
    }

    /**
     * @dev pixel distributor contract 주소 등록
     *
     * @param _pixelDistributor 컨트렉트 주소
     */
    function setPixelDistributor(address _pixelDistributor) external onlyOwner validAddress(_pixelDistributor){
        distributor = _pixelDistributor;

        emit SetPixelDistributor(msg.sender, _pixelDistributor);
    }

    event AddUser(address indexed _sender, address indexed _user);
    event AddContents(address indexed _sender, address indexed _contents);
    event AddContentsDistributor(address indexed _sender, address indexed _contentsDistributor, uint256 _count);
    event AddCouncils(address indexed _sender, address indexed _council, uint256 _count);
    event SetContentsDistributorRate(address indexed _sender, uint256 _rate);
    event SetPixelDistributor(address indexed _sender, address _pixelDistributor);
}
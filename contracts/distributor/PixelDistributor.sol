pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "contracts/interface/IPictionNetwork.sol";
import "contracts/interface/IContents.sol";

import "contracts/piction/CustomToken.sol";
import "contracts/piction/ContractReceiver.sol";

import "contracts/utils/ValidValue.sol";
import "contracts/utils/BytesLib.sol";

contract PixelDistributor is ContractReceiver, ValidValue{
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using BytesLib for bytes;

    uint256 public constant DECIMALS = 10 ** 18;        // Pixel token decimals

    address token;                                      // Pixel token address
    IPictionNetwork piction;                            // Piction network contract address

    /**
     * @dev 생성자
     *
     * @param _piction piction network contract
     */
    constructor(address _piction) public validAddress(_piction) {
        piction = IPictionNetwork(_piction);
        token = piction.getPxlAddress();
    }

    /**
     * @dev 콘텐츠 판매에 따른 분배 처리
     *
     * @param _from 구매자 주소
     * @param _value 콘텐츠 판매 금액
     * @param _token Pixel token address
     * @param _data bytes로 구성된 파라미터(contents distributor 주소, 판매 된 contents 주소)
     */
    function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public {
        require(address(this) != _from, "Purchase faild: Invalid buyer address.");
        require(token == _token, "Purchase faild: Invalid PIXEL token address.");
        require(piction.validUser(_from), "Purchase faild: Invalid user, Please use piction after signing up..");

        address cd = _data.toAddress(0);
        address contents = _data.toAddress(20);

        require(piction.isContentsDistributor(cd), "Purchase faild: Invalid contents distributor address.");
        //require(piction.validContents(contents), "Purchase faild: Invalid contents address.");

        IContents(contents).purchase(_from, _value);

        if(_value > 0) {
            //베타에서 픽셀 내역을 표기할지 확인 필요
            CustomToken(token).transferFromPxl(_from, address(this), _value, "에피소드 구매");
            _distributePurchaseTokens(IContents(contents).getOwner(), _from, cd, _value);
        }
    }

    /**
     * @dev 분배 내역 계산 및 토큰 전송을 처리하는 내부 함수
     *
     * @param _writer contents provider 주소
     * @param _buyer 구매자 주소
     * @param _cd contents distributor 조수
     * @param _value contents 판매 금액
     */
    function _distributePurchaseTokens(address _writer, address _buyer, address _cd, uint256 _value) private {
        uint256 amount;
        uint256 remainToken = _value;

        // contents distributor 
        amount = _convertedToPixel(_value, piction.getCdRate());
        remainToken = remainToken.sub(amount);
        CustomToken(token).transferPxl(_cd, amount, "Contents Distributor fees");
        emit PixelDistribution(_cd, amount, _value, "Contents Distributor fees");

        // contents provider
        CustomToken(token).transferPxl(_writer, remainToken, "Revenue from the sale of contents");
        emit PixelDistribution(_writer, remainToken, _value, "Revenue from the sale of contents");
    }

    function _convertedToPixel(uint256 _amount, uint256 _rate) private pure returns (uint256) {
        return _amount.mul(_rate).div(DECIMALS);
    }

    event PixelDistribution(address indexed _to, uint256 _amount, uint256 _contentsPrice, string _message);
}
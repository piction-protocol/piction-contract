pragma solidity ^0.4.24;

import "contracts/utils/Hashable.sol";

contract Comic is Hashable {
    
    address[] episodes;     //Comic과 mapping 된 episode contract 주소

    /**
     * @dev 생성자
     *
     * @param _hash Comic의 정보를 사용하여 생성한 hash string
     */
    constructor (string _hash) public {
        setHash(_hash);
        
        emit CreateComic(msg.sender, _hash);
    }

    /**
     * @dev episode 추가 
     *
     * @param _episode 배포가 완료 된 episode contract 주소
     */
    function addEpisode(address _episode) public onlyOwner validAddress(_episode) {
        episodes.push(_episode);

        emit AddEpisode(msg.sender, _episode, (episodes.length - 1));
    }

    /**
     * @dev episode 조회 
     *
     * @return episodes_ Comic에 mapping 되어 있는 episode의 주소 목록
     */
    function getEpisodes() public view returns(address[] episodes_) {
        return episodes;
    }

    /**
     * @dev episode 조회
     *
     * @param _index mapping 되어 있는 episode index
     * @return episode_ index에 해당하는 episode 주소
     */
    function getEpisode(uint256 _index) public view returns(address episode_) {
        if(episodes.length >= _index) {
            episode_ = episodes[_index];
        }
        return episode_;
    }

    event CreateComic(address indexed _user, string _hash);
    event AddEpisode(address indexed _user, address indexed _episode, uint256 _index);
}
/*
    Copyright 2022 Project Galaxy.
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    SPDX-License-Identifier: Apache License, Version 2.0
*/

pragma solidity >0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import  "./StarNFTV3.sol";


contract StarNFTV3NaiveFactory is Ownable{
    string constant baseURI = "https://graphigo.prd.galaxy.eco/metadata/";
    address public manager;
    bool public paused;
    mapping(address => mapping(uint256 => address)) public nftMap; // we allow same address to create NFTs
    mapping(address => uint256) public nftNumber;
    address[] public allNFTs;
    

    event NFTCreated(
        address indexed minter,
        address indexed creator,
        address owner,
        address starAddr,
        uint256 length,
        string name,
        string symbol
    );

    /**
     * Throws if the contract paused
     */
    modifier onlyNoPaused() {
        _validateOnlyNotPaused();
        _;
    }

    constructor(address _manager) {
        manager = _manager;
    }


    function allNFTsLength() external view returns (uint256) {
        return allNFTs.length;
    }

    function getOneNFT(address _creator, uint256 idx)
        external
        view
        returns (address)
    {
        return nftMap[_creator][idx];
    }

    function getRecentNFT(address _creator) external view returns (address) {
        uint256 idx = nftNumber[_creator] - 1;
        return nftMap[_creator][idx];
    }

    function setManager(address _manager) external onlyOwner{
        manager = _manager;
    }

    function createStarNFT(
        address _minter,
        address _owner,
        string memory _name,
        string memory _symbol
    ) external onlyNoPaused returns (address starAddr) {
        uint256 count = nftNumber[_owner];
        bytes32 salt = keccak256(abi.encodePacked(_owner, count));

        bytes memory bytecode = type(StarNFTV3).creationCode;
        bytecode = abi.encodePacked(bytecode,abi.encode(_name,_symbol));

        assembly {
            starAddr := create2(0, add(bytecode, 20), mload(bytecode), salt)
        }

        nftMap[_owner][count] = starAddr;
        allNFTs.push(starAddr);
        nftNumber[_owner] = nftNumber[_owner] + 1;

        StarNFTV3 snf = StarNFTV3(starAddr);
        // StarNFT721(point)(cap) share the same ABI
        snf.addMinter(_minter);
        snf.setBaseURI(string(
                abi.encodePacked(baseURI, "0x", toAsciiString(starAddr), "/")
            ));
        snf.transferOwnership(_owner);

        emit NFTCreated(
            _minter,
            msg.sender,
            _owner,
            starAddr,
            allNFTs.length,
            _name,
            _symbol
        );
        // can not return value here
    }

    receive() external payable {
        // anonymous transfer: to treasury_manager
        (bool success, ) = address(this).call{value: msg.value}(
            new bytes(0)
        );
        require(success, "Transfer failed");
    }
    
    fallback() external payable {
       
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Function that pause the contract.
     */
    function setPause(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function _validateOnlyManager() internal view {
        require(msg.sender == manager, "Only manager can call");
    }

    function _validateOnlyNotPaused() internal view {
        require(!paused, "Contract paused");
    }

    function toAsciiString(address x) internal view returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal view returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}

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

pragma solidity > 0.8.0;


//Implement the ERC721A contract for saving the gas cost in batch minting and burning 
// MoreInfo on ERC721A: https://www.azuki.com/erc721a
import "../ERC721A/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// import "./IStarNFT.sol";


contract StarNFTV3 is ERC721A,Ownable {
    using Strings for uint256;
    event EventMinterAdded(address indexed newMinter);
    event EventMinterRemoved(address indexed oldMinter);
    event BaseURLChanged(string oldBaseurl, string newBaseurl);
    
    mapping (address=>bool) public minters;

    string private baseURI;
    // bool public transferable = true;  // Doesn't make any sense becuase contract owner paused the transfer than other NFTs owner can't transfer their own NFTs (Bad User Expirence)

    modifier onlyMinter() {
        require(minters[msg.sender], "You are not minter.");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC721A(_name,_symbol){

    }

    // function setTransferable(bool _transferable) external onlyOwner {
    //     transferable = _transferable;
    // }

    function addMinter(address _user) external onlyOwner {
        require(_user != address(0), "Minter must not be null address");
        require(!minters[_user], "Minter already added");
        minters[_user] = true;
        emit EventMinterAdded(_user);
    } 

    function mint(address to) public onlyMinter {
        _safeMint(to,1);
    }
    
    function mintBatch(address to, uint256 quantity) public onlyMinter {
        _safeMint(to,quantity);
    }

    function _baseURI() internal view override returns(string memory) {
        return baseURI;
    }
    
    function setBaseURI(string memory url) external onlyOwner() {
        baseURI = url;
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
          if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString(),".json")) : '';
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function burnBatch(uint256[] calldata tokenIds) public {
        uint256 idsLength = tokenIds.length;
        unchecked {
        for(uint i=0 ; i < idsLength; i++) {
            _burn(tokenIds[i],false);
        }
        }
    }

    function removeMinter(address minter) external onlyOwner {
        require(minters[minter], "Minter does not exist");
        delete minters[minter];
        emit EventMinterRemoved(minter);
    }


    // Remove the transferable functionality 

    // function transferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) public override {
    //     require(transferable, "disabled");
    //     require(
    //         _isApprovedOrOwner(_msgSender(), tokenId),
    //         "ERC721: caller is not approved or owner"
    //     );
    //     _transfer(from, to, tokenId);
    // }

    // /**
    //  * @dev See {IERC721-safeTransferFrom}.
    //  */
    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId
    // ) public override {
    //     require(transferable, "disabled");
    //     require(
    //         _isApprovedOrOwner(_msgSender(), tokenId),
    //         "ERC721: caller is not approved or owner"
    //     );
    //     safeTransferFrom(from, to, tokenId, "");
    // }

    // /**
    //  * @dev See {IERC721-safeTransferFrom}.
    //  */
    // function safeTransferFrom(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     bytes memory _data
    // ) public override {
    //     require(transferable, "disabled");
    //     require(
    //         _isApprovedOrOwner(_msgSender(), tokenId),
    //         "ERC721: caller is not approved or owner"
    //     );
    //     _safeTransfer(from, to, tokenId, _data);
    // }

}
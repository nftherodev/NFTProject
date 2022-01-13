// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract MarbleHero is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => bool) private _minters;

    string public _baseUri = "https://www.heronft.com/"; // Initial base URI

    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event Mint(address indexed _owner, uint256 _tokenId);
    event BatchMint(address indexed _owner, uint256 _count);
    event Burn(address indexed _owner, uint256 _tokenId);
    event SetBaseURI(string _baseUri);

    modifier onlyMinter() {
        require(_minters[_msgSender()], "ERC721: caller is not the minter");
        _;
    }

    constructor() ERC721("nft", "nft") {

    }
    
    function secureBaseUri(string memory newUri) public onlyMinter {
        _baseUri = newUri;
        emit SetBaseURI(newUri);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokensOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return new uint256[](0);
        else {
            uint256[] memory result = new uint256[](tokenCount);
            for (uint256 index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    function mint(address owner) external onlyMinter returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _approve(msg.sender,newItemId);

        emit Mint(owner, newItemId);
        return newItemId;
    }

    function batchMint(address owner, uint256 count) external onlyMinter {
         for(uint256 index = 0; index < count; index++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(owner, newItemId);
         }
         emit BatchMint(owner, count);
    }
    
    function burn(uint256 tokenId) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
        emit Burn(msg.sender, tokenId);
    }

    function addMinter(address minter) external onlyOwner {
        require(minter != address(0), "Minter must not be null address");
        require(!_minters[minter], "Minter already added");
        _minters[minter] = true;
        emit MinterAdded(minter);
    }

    function removeMinter(address minter) external onlyOwner {
        require(_minters[minter], "Minter does not exist");
        delete _minters[minter];
        emit MinterRemoved(minter);
    }

    function isMinter(address minter) external view returns(bool) {
        return _minters[minter];
    }
    
}
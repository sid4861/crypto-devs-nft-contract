//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    /**
     * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    string _baseTokenURI;

    //price of 1 nft
    uint256 public _price = 0.01 ether;

    //used to pause a contract
    bool public _paused;

    //max number of cryptodevs
    uint256 public maxTokenIds = 20;

    //total number of tokenids minted
    uint256 public tokenIds;

    //whitelist contract instance
    IWhitelist whitelist;

    //to track if presale has started
    bool public presaleStarted;

    //timestamp for when presale would end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused() {
        require(!_paused, "contract currently paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract)
        ERC721("Crypto devs", "CD")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    /**
        @dev starts a presale for whitelisted addresses
         */
    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    /**
         @dev presaleMint allows a user to mint 1 NFT per transaction during presale period
          */

    function presaleMint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp < presaleEnded,
            "presale is not running"
        );
        require(
            whitelist.whitelistedAddresses(msg.sender),
            "your address is not whitelisted"
        );
        require(tokenIds < maxTokenIds, "exceeded maximum token supply");
        require(msg.value >= _price, "amount is not enough");

        tokenIds += 1;

        _safeMint(msg.sender, tokenIds);
    }

    /**
        @dev mint allows a user to mint 1 mint per transaction after the presale period has ended
         */
    function mint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp > presaleEnded,
            "presale has not ended"
        );
        require(tokenIds < maxTokenIds, "exceeded total token supply");
        require(msg.value >= _price, "ether amount is not correct");

        tokenIds += 1;

        _safeMint(msg.sender, tokenIds);
    }

    /**
        @dev overrides erc721 implementation
         */

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /**
         @dev sends all the ether from contract to contract's owner
          */

    function withdraw() public onlyOwner {
        address owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "failed to withdraw");
    }
    receive() external payable {}
    fallback() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';


contract NFTransport is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, ChainlinkClient {
    using Counters for Counters.Counter;
    
    /***chainlink***/
    using Chainlink for Chainlink.Request;
    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;

    event RequestVolume(bytes32 indexed requestId, uint256 volume);
    /***************/

    Counters.Counter private _tokenIdCounter;

        //setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        //setChainlinkOracle(0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656);
        //jobId = 'ca98366cc7314957b8c012c72f05aeeb';

    
    constructor() ERC721("NFTransport", "NFT") {
    
    /***chainlink***/ //market.link not available during our transition from mumbai to rinkeby (for frontend issues)
    setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
    setChainlinkOracle(0xc8D925525CA8759812d0c299B90247917d4d4b7C);
    jobId = 'e5672029986e4cb793c88433c7d7b953';
    fee = (1 * LINK_DIVISIBILITY) / 100; // 0,1 * 10**18 (Varies by network and job)
    /***************/
    }
    // Adding support for multiple token URIs
    mapping(uint256 => string) private _tokenURIsRedeemed;
    string  _uriRedeemable = "https://gateway.pinata.cloud/ipfs/QmdWrjJa2wNQ1Wzc472PBbvaso9y2obzzJV8Vo18qwJN6t/redeemable.json";
    string  _uriRedeemed = "https://gateway.pinata.cloud/ipfs/QmdWrjJa2wNQ1Wzc472PBbvaso9y2obzzJV8Vo18qwJN6t/redeemed.json";


    /***chainlink***/
    function requestRedeemedData(string memory str) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        req.add('get', 'https://jtgxeyqd5ctklv53m5lmghinmy0qkfql.lambda-url.eu-west-1.on.aws/');

        req.add('uri', str); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10**18;
        req.addInt('times', timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }
    function fulfill(bytes32 _requestId, uint256 _tokenId) public recordChainlinkFulfillment(_requestId) {
        _setTokenURI(_tokenId, "https://gateway.pinata.cloud/ipfs/QmdWrjJa2wNQ1Wzc472PBbvaso9y2obzzJV8Vo18qwJN6t/redeemed.json");
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
    /***************/


    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint() public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _uriRedeemable);
    }

    //function called when user want to redeem
    //add chainlink with input of tokenid at least, or directly TokenURIredeemed
    function redeem(uint256 tokenId, string memory redeemFormEncryptedURI) public {
        require(msg.sender == this.ownerOf(tokenId));
        _setTokenURIredeemed(tokenId, redeemFormEncryptedURI);
        requestRedeemedData(redeemFormEncryptedURI);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    function tokenURIRedeemed(uint256 tokenId) public view virtual returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        string memory _tokenURIRedeemed = _tokenURIsRedeemed[tokenId];

        return _tokenURIRedeemed;
    }

    function _setTokenURIredeemed(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIsRedeemed[tokenId] = _tokenURI;
    }
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}

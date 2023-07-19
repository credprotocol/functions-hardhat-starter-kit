// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CredTag is ERC721, ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  using Strings for uint256;

  /* ///////////////////////////////////////////////////////////////
  VARIABLES
  ////////////////////////////////////////////////////////////// */

  // tokenId counter
  Counters.Counter private _tokenIdCounter;

  // base URI
  string public baseURI;

  // contract URI
  string public contractURI;

  // oracle address - can update the score
  address public oracle;

  // Cred score mapping
  mapping(address => uint256) public credScore;

  // Cred score timestamp
  mapping(address => uint256) public credScoreTimestamp;

  // mapping of minted CredTags
  mapping(address => uint256) public minted;

  // mapping of CredTag owners
  mapping(uint256 => address) public credTagOwner;

  /* ///////////////////////////////////////////////////////////////
  EVENTS
  ////////////////////////////////////////////////////////////// */

  // triggered when a base URI of a token is changed
  event BaseURIChanged(string newBaseURI);

  // triggered when a contract URI of the collection is changed
  event ContractURIChanged(string newContractURI);

  // triggered when a CredTag is minted
  event Minted(address minter);

  // triggered when a Cred score is updated
  event CredScoreUpdated(address user, uint256 score, uint256 timestamp);

  // triggered when an oracle address is updated
  event OracleUpdated(address wallet);

  /* ///////////////////////////////////////////////////////////////
  CONSTRUCTOR
  ////////////////////////////////////////////////////////////// */

  /**
   * @dev
   * `initBaseURI` refers to an address of a collection folder on Arweave
   * `initContractURI` refers to an address of a collection metadata on Arweave
   */
  constructor(string memory initBaseURI, string memory initContractURI) ERC721("CredTag", "CredTag") {
    baseURI = initBaseURI;
    contractURI = initContractURI;
  }

  /* ///////////////////////////////////////////////////////////////
  ACCESS CONTROLLED FUNCTIONS
  ////////////////////////////////////////////////////////////// */

  /**
   * @notice Set a base URI that holds metadata of tokens
   * @param  newBaseURI : new URI of the metadata folder
   */
  function setBaseURI(string calldata newBaseURI) external onlyOwner {
    baseURI = newBaseURI;
    emit BaseURIChanged(newBaseURI);
  }

  /**
   * @notice Set a contract URI that holds the metadata about the collection
   * @param  newContractURI : new URI of the collection data
   */
  function setContractURI(string calldata newContractURI) external onlyOwner {
    contractURI = newContractURI;
    emit ContractURIChanged(newContractURI);
  }

  /**
   * @notice ERC721 override of _beforeTokenTransfer restricted to minting only
   * @param  from : address of the sender
   * @param  to : address of the receiver
   * @param  tokenId : id of the token
   * @param  batchSize : number of tokens to transfer
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override(ERC721) {
    require(from == address(0), "Token not transferable");
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
  }

  /**
   * @notice Mints a token for the user
   */
  function safeMint() public {
    require(minted[msg.sender] == 0, "CredTag already minted");
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    _safeMint(msg.sender, tokenId);
    minted[msg.sender] = 1;
    credTagOwner[tokenId] = msg.sender;
    emit Minted(msg.sender);
  }

  /**
   * @notice Updates the Cred score of the user
   * @param  score : new Cred score
   */
  function updateCredScore(uint256 score, address wallet) public {
    require(msg.sender == oracle, "Score can be updated only by oracle");
    require(minted[wallet] == 1, "CredTag not minted");
    credScore[wallet] = score;
    credScoreTimestamp[wallet] = block.timestamp;
    emit CredScoreUpdated(wallet, score, block.timestamp);
  }

  /**
   * @notice Updates the oracle address that can update the score
   * @param  wallet : new oracle address
   */
  function updateOracleAddress(address wallet) external onlyOwner {
    oracle = wallet;
    emit OracleUpdated(wallet);
  }

  /* ///////////////////////////////////////////////////////////////
  SOLIDITY REQUIRED OVERRIDES
  ////////////////////////////////////////////////////////////// */

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    require(_exists(tokenId), "Token does not exist");
    // getCredScore for tokenId
    address owner = ERC721.ownerOf(tokenId);
    uint256 score = credScore[owner];

    return string(abi.encodePacked(baseURI, score.toString(), ".json"));
  }
}

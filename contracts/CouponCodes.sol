// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CouponCodes is ERC721Enumerable, ReentrancyGuard, VRFConsumerBaseV2  {
  using Counters for Counters.Counter;
  Counters.Counter private _nextTokenId;
  mapping(uint256 => uint256) public tokenIdToRequest;

  // *** probability constants ***
  // total range
  uint256 constant MIN = 1;
  uint256 constant MAX = 10;
  // discounts
  uint256 constant FIFTEEN_PERC = 7; // 70%
  uint256 constant TWENTY_PERC = 9; // 20%
  uint256 constant THIRTY_PERC = 10; // 10%

  // *** chainlink ***
  VRFCoordinatorV2Interface public immutable COORDINATOR;
  uint32 constant CALLBACK_GAS_LIMIT = 100000;
  uint16 constant REQUEST_CONFIRMATIONS = 3;
  uint32 constant NUM_WORDS = 1;
  uint64 public immutable s_subscriptionId;
  bytes32 public immutable s_keyHash;
  
  uint256[] public requestIds;
  uint256 public lastRequestId;
  struct RequestStatus {
    bool fulfilled;
    bool exists;
    bool redeemed;
    uint256 randomWord;
    uint256 tokenId;
    address account;
  }
  mapping(uint256 => RequestStatus) public s_requests;

  // *** events ***
  event RequestSent(uint256 requestId, uint32 numWords, address indexed account, uint256 tokenId);
  event RequestFulfilled(uint256 requestId, uint256 randomWord, address indexed account, uint256 tokenId);
  event CouponCodeRedeemed(uint256 requestId, uint256 randomWord, address indexed account, uint256 tokenId);

  constructor(
    uint64 subscriptionId,
    address vrfCoordinator,
    bytes32 keyHash
  ) ERC721("KohlsCouponCodes", "KCC") 
    VRFConsumerBaseV2(vrfCoordinator) {
    // chainlink
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_keyHash = keyHash;
    s_subscriptionId = subscriptionId;
    // start at token id = 1
    _nextTokenId.increment();
  }

  // Chainlink - create random word request
  // Create coupon code
  // NOTE: In production, add access control role
  function requestRandomWords(address account_) external nonReentrant returns(uint256) {
    uint256 requestId = COORDINATOR.requestRandomWords(
      s_keyHash,
      s_subscriptionId,
      REQUEST_CONFIRMATIONS,
      CALLBACK_GAS_LIMIT,
      NUM_WORDS
    );

    // mint NFT coupon code
    uint256 tokenId = _nextTokenId.current();
    _mint(account_, tokenId);
    tokenIdToRequest[tokenId] = requestId;

    // chainlink request
    s_requests[requestId] = RequestStatus({
      randomWord: 0,
      exists: true,
      fulfilled: false,
      redeemed: false,
      account: account_,
      tokenId: tokenId
    });
    requestIds.push(requestId);
    lastRequestId = requestId;

    // event
    emit RequestSent(requestId, NUM_WORDS, account_, tokenId);

    // increment to next token id
    _nextTokenId.increment();

    return requestId;
  }

  // Chainlink - fulfill random word request
  // Reveal coupon code discount
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
    internal
    override
  {
    require(s_requests[requestId].exists, "REQUEST_NOT_FOUND");
    s_requests[requestId].fulfilled = true;
    // mod random word into set range
    uint256 randomNumber = (randomWords[0] % MAX) + MIN;
    address account = s_requests[requestId].account;
    uint256 tokenId = s_requests[requestId].tokenId;
    s_requests[requestId].randomWord = randomNumber;

    //event
    emit RequestFulfilled(requestId, randomNumber, account, tokenId);
  }

  // Get chainlink request status
  function getRequestStatus(
    uint256 _requestId
  ) external view returns (bool fulfilled, uint256  randomWord) {
    require(s_requests[_requestId].exists, "REQUEST_NOT_FOUND");
    RequestStatus memory request = s_requests[_requestId];
    return (request.fulfilled, request.randomWord);
  }

  // redeem coupon code discount
  function redeemCouponCode(uint256 tokenId_) public nonReentrant() {
    require(ownerOf(tokenId_) == msg.sender, 'CALLER_NOT_OWNER');
    
    uint256 requestId = tokenIdToRequest[tokenId_];
    s_requests[requestId].redeemed = true;
    _burn(tokenId_);

    emit CouponCodeRedeemed(requestId, s_requests[requestId].randomWord, s_requests[requestId].account, tokenId_);
  }
}
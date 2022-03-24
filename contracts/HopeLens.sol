// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
import 'https://github.com/aave/lens-protocol/blob/main/contracts/libraries/DataTypes.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBase.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

///@title a GiveAway draw luck using Chainlink randomness and Lens API 
///@author Mehdi.R
///Functions from LensHub.sol (https://docs.lens.dev/docs/functions) 
abstract contract LensHub {

    function initialize(string calldata name, string calldata symbol, address newGovernance) virtual external;
    
}

contract HopeLensGiveAway is VRFConsumerBase{

    LensHub HopeLens; 

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    uint256 public _counter = 0;
    uint256 public entryAmount = 2000; 
    address payable[] public participants;

    event NewWinner(uint256 id, uint256 nftId, address winner, uint256 timestamp);



    mapping(uint256 => GiveAway[]) listOfGiveAway;
    mapping(uint256 => Winner) public winners;

    struct GiveAway {
        address creator;
        uint256 profileId; 
        uint256 amount;
    }

    struct Winner {
        uint256 id;
        uint256 total;
        address recipient; 
        uint256 timestamp;
    }

    uint256 public _winnersCounter = 0;
    IERC20 public _superToken;



    /// CONSTRUCTOR

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Mumbai Testnet
     * Chainlink VRF Coordinator address: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
     */

    //https://docs.chain.link/docs/vrf-contracts/v1/ for addresses
    constructor() VRFConsumerBase(0x8C7382F9D8f56b33781fE506E897a4F1e2d17255,0x326C977E6efc84E512bB9C30f76E30c160eD06FB) public {
        address proxyAddress = 0xd7B3481De00995046C7850bCe9a5196B7605c367; // LensHub proxy on mumbai testnet
        HopeLens = LensHub(proxyAddress);
        //HopeLens.initialize("HopeLens", "HL", msg.sender);
    }

    function getRandomResult() public view returns (uint256) {
        return randomResult;
    } 

    function getRandomNumber() public returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        // get random number between 1 and 1000
        defineWinner(randomness);
    }

    function createGiveAway(uint256 _amount, uint256 profileId) public returns (GiveAway memory){
        address creator = msg.sender ;
        GiveAway memory giveAway = GiveAway(creator, profileId, _amount);
        listOfGiveAway[profileId].push(giveAway);
        return giveAway; 
    }

    function addParticipants() public payable {
        require(msg.value >= entryAmount);
        participants.push(payable(msg.sender));
        _counter ++ ; 
    }

    function defineWinner(uint256 randomness) private {
        uint256 winnerId = randomness % _counter;
        address recipient = msg.sender; 
        winners[_winnersCounter] = Winner(winnerId, _counter, recipient, block.timestamp);
        _superToken.transfer(recipient, 1 * 10**18);
        emit NewWinner(_winnersCounter, winnerId, recipient, block.timestamp);
        _winnersCounter++;
    }




}



























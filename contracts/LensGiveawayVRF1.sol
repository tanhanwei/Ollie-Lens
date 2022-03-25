// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;

//import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBase.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

contract LensGiveaway is VRFConsumerBase{

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    uint256 public random;

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
        //HopeLens = LensHub(proxyAddress);
        //HopeLens.initialize("HopeLens", "HL", msg.sender);
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
        // get random number 
        randomness;
    }
    

    //ORGANIZER
    struct Giveaway {
        Prize prize; //type of prize
        Condition condition; //giveaway conditions
        uint deadline; //end date
        uint256 cost; //the price that participants need to pay

        //Prize details
        uint256 amount; //amount of MATIC prize
        address nftScAddress; //NFT smart contract address for ownership transfer reference
        uint256 nftTokenId; //The NFT that will be given away

        //those who joined
        address[] participants;
        address winner;
        uint256 randomIndex;

        //giveaway status
        bool ended;

        //claim status
        bool claimed;
        
    }

    struct Condition {
        bool like;
        bool follow;
        bool mirror;
        bool comment;
    }

    enum Prize {MATIC, NFT}

    mapping(uint => Giveaway) private GiveawayList;

    struct ProfileGiveaway {
        Giveaway[] giveawayList;
    }

    mapping(address => ProfileGiveaway) private profileGiveaway;

    //PARTICIPANTS
    struct Participations {
        GiveawayJoined[] giveawayJoined;
    }

    struct GiveawayJoined {
        address organizer;
        uint256 giveawayId;
        bool isWinner;
    }

    mapping(address => Participations) participations;

    //-----------------------------ORGANIZER START A GIVEAWAY-----------------------------------

    function addGiveaway (Prize prize, Condition memory condition, uint deadline, uint cost, uint256 amount, address nftScAddress, uint nftTokenId) public payable returns (uint256){
        address organizer = msg.sender;
        Giveaway memory giveaway;
        giveaway = Giveaway({prize:prize, condition:condition, deadline:deadline, cost:cost, amount:amount, nftScAddress:nftScAddress, nftTokenId:nftTokenId, participants: new address[](0), winner: address(0), randomIndex:0, ended: false, claimed:false});

        profileGiveaway[organizer].giveawayList.push(giveaway);
        
        //Payment for Prize
        require( msg.value >= amount);

        return profileGiveaway[organizer].giveawayList.length; //returns giveawayId
    }

    //--------------------------------PARTICIPANTS JOIN A GIVEAWAY---------------------------

    function addParticipant (address organizer, uint giveawayId, uint256 amount) public payable {
        //TODO: check participation condition
        //update organizer's mapping
        require (amount >= profileGiveaway[organizer].giveawayList[giveawayId].cost, "Amount less than cost");
        require (!isCurrentParticipant(organizer, giveawayId, msg.sender), "Existing participant");
        profileGiveaway[organizer].giveawayList[giveawayId].participants.push(msg.sender);

        //update participant's mapping
        GiveawayJoined memory joining;
        joining = GiveawayJoined({organizer:organizer, giveawayId:giveawayId, isWinner:false});

        participations[msg.sender].giveawayJoined.push(joining);
    }

    function isCurrentParticipant(address organizer, uint giveawayId, address participant) public view returns (bool){
        bool condition;
        for(uint256 i=0; i < profileGiveaway[organizer].giveawayList[giveawayId].participants.length && !condition; i++){
            if (profileGiveaway[organizer].giveawayList[giveawayId].participants[i] == participant) {
                condition = true;
            } else {
                condition = false;
            }
        }
        return condition;
    }

    //----------------------------------END GIVEAWAY BY DRAWING----------------------------------------

    function selectWinner(address organizer, uint giveawayId) public payable returns (address){
        uint256 winnerIndex;
        address winnerAddress;
        require(msg.sender == organizer, "Unauthorized, sender is not the organizer");


        winnerIndex = random % profileGiveaway[organizer].giveawayList[giveawayId].participants.length;
        winnerAddress = profileGiveaway[organizer].giveawayList[giveawayId].participants[winnerIndex];
        
        //setWinner
        profileGiveaway[organizer].giveawayList[giveawayId].winner = winnerAddress;
        profileGiveaway[organizer].giveawayList[giveawayId].ended = true;

        return winnerAddress;
    
    }


    function getLatestGiveawayIndex(address organizer) public view returns (uint256){
        return profileGiveaway[organizer].giveawayList.length;
    }

   

    //-------------------------CHECK GIVEAWAY STATUS---------------------------------

    function getParticipants (address organizer, uint giveawayId) public view returns (address[] memory) {
        return profileGiveaway[organizer].giveawayList[giveawayId].participants;
    }

    function getWinner(address organizer, uint giveawayId) public view returns (address) {
        require (profileGiveaway[organizer].giveawayList[giveawayId].ended, "Giveaway not ended");
        return profileGiveaway[organizer].giveawayList[giveawayId].winner;
    }

    //-------------------------PRIZE CLAIMING--------------------------------------
    function getMyEntries() public view returns (Participations memory){
        return participations[msg.sender];
    }

    function withdrawMyMaticPrize(address organizer, uint giveawayId) public payable {
        uint256 prizeAmount;
        
        require(msg.sender == profileGiveaway[organizer].giveawayList[giveawayId].winner, "Invalid claim");
        prizeAmount = profileGiveaway[organizer].giveawayList[giveawayId].amount;
        require(payable(msg.sender).send(prizeAmount));
        profileGiveaway[organizer].giveawayList[giveawayId].claimed = true;
    }
    
}

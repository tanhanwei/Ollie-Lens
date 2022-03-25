// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.10;

import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
import 'https://github.com/aave/lens-protocol/blob/main/contracts/libraries/DataTypes.sol';
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LensGiveaway is VRFConsumerBaseV2{
    //CHAINLINK STUFF
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

    // Rinkeby LINK token contract. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  2;

    uint256[] public s_randomWords;
    //uint256 public s_requestId;
    //address s_owner;

      constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        //s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
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

        uint256 randomWord = requestRandomWords();

        winnerIndex = randomWord % profileGiveaway[organizer].giveawayList[giveawayId].participants.length;
        winnerAddress = profileGiveaway[organizer].giveawayList[giveawayId].participants[winnerIndex];
        
        //setWinner
        profileGiveaway[organizer].giveawayList[giveawayId].winner = winnerAddress;
        profileGiveaway[organizer].giveawayList[giveawayId].ended = true;

        return winnerAddress;
    }

    function requestRandomWords() public returns(uint256){
        //changed s_requestId to a temp variable
        uint256 s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );

        return s_requestId;
    }
    
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function getLatestGiveawayIndex(address organizer) public view returns (uint256){
        return profileGiveaway[organizer].giveawayList.length;
    }

    function setNumWords (uint32 number) public {
        numWords = number;
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


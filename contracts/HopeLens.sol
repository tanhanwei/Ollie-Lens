// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
import 'https://github.com/aave/lens-protocol/blob/main/contracts/libraries/DataTypes.sol';

///@title a GiveAway draw luck using Chainlink randomness and Lens API 
///@author Mehdi.R
///Functions from LensHub.sol (https://docs.lens.dev/docs/functions) 
abstract contract LensHub {

    ///@notice Initialize the proxy contract 
    ///@param name for the LensProfile NFT, symbol for the lensPorfile NFT, Governance address
    function initialize(string calldata name, string calldata symbol, address newGovernance) external;
    function getProfileIdByHandle(string calldata handle) external view returns (uint256);

    ///@notice Setting up the Emergency Address to upgrade security 
    ///@param newEmergencyAdmin address set up by the governance address 
    function EmergencyAdmin(address newEmergencyAdmin) external;

    ///@notice sets the Whitelist state of a ProfileCreator (whitelisted / not Whitelisted) 
    ///@param profileCreator address 
    ///@return boolean whether a ProfileCreator is whitelisted or not 
    function whitelistProfileCreator(address profileCreator, bool whitelist) external; 

    ///@notice Profile Creation with Following Module handle 
    ///address to mint to, new profile handle, URI for new profile image, follow module for new profile or 0x,
    ///URI for the followNFT of the profile 
    function createProfile(DataTypes.CreateProfileData calldata vars) external;


    ///@notice setting up the following Module for a Profile 
    ///@param profileId, followModule for the address of the Profile to set to
    /// FollowModule should be whitelisted 
    function setFollowModule(uint256 profileId, address followModule, bytes calldata followModuleData) external;

    ///notice sets the URI for the profile 
    ///@param profileId, URI choosen for this profile 
    function setProfileImageURI(uint256 profileId, string calldata imageURI) external;

    ///@notice sets a Follow NFTUIR for a profile 
    ///@param profileId,  URI for the followNFT 
    function setFollowNFTURI(uint256 profileId, string calldata followNFTURI) external;

    ///@notice publish a post for a given Profile
    ///profileId, contentURI, collectModule(address) for the post, referenceModule, 
    ///require(collectModule == whitelisted & 0x)
    ///mapping(DataTypes => profileId) mapping a publication to a profileId with a counter +1 
    function post(DataTypes.PostData calldata vars) external;

    ///@notice publish a comment to a profileId 
    ///profileId, URI of post to set
    ///pointer to the profileId and publicationId 
    ///function comment(DataTypes.CommentData calldata vars) external;


    ///@notice follows the given profileId's 
    function follow(uint256[] calldata profileIds, bytes[] calldata datas) external;

    ///@notice collects a given publication and mints an NFT to the follower 
    ///@param profileId and pubId that created a post 
    ///mapping to the collector in the collect NFT map ; mapping(collector => collectNFT[]) 
    function collect(uint256 profileId, uint256 pubId, bytes calldata data) external;

    ///@notice emit an event when a collectNFT is created 
    function emitCollectNFTTransferEvent(uint256 profileId, uint256 pubId, uint256 collectNFTId, address from, address to) external;

    function getFollowNFT(uint256 profileId) external view returns (address);
    function getCollectNFT(uint256 profileId, uint256 pubId) external view returns (address);
    function getFollowNFTURI(uint256 profileId) external view returns (string memory);
    function getHandle(uint256 profileId) external view returns (string memory);
    function getContentURI(uint256 profileId, uint256 pubId) external view returns (string memory);
}


contract HopeLensGiveAway {

    LensHub HopeLens; 

    mapping(uint256 => GiveAway[]) listOfGiveAway; 


    struct GiveAway {
        address creator;
        uint256 profileId; 
        uint256 amount;
        //mapping(address => string) participants; //participant with profileId 
        //string _publication;
        //address winner; 
    }

     constructor() public {
        address proxyAddress = 0xd7B3481De00995046C7850bCe9a5196B7605c367; // LensHub proxy on mumbai testnet
        HopeLens = LensHub(proxyAddress);
        HopeLens.initialize("HopeLens", "HL", msg.sender);
    }

    //function defineWinner()

    function createGiveAway(uint256 _amount, uint256 profileId) public returns (GiveAway memory){
        address creator = msg.sender ;
        GiveAway memory giveAway = GiveAway(creator, profileId, _amount);
        listOfGiveAway[profileId].push(giveAway);
        return giveAway; 
    }

    function defineWinner() ; 

    function addParticipant() ; 


    function Randomness();

    

   // function Publication(uint256 profileId) public view returns(string[] memory _publication) {}
        





}


























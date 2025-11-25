// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TenchatIdentity is Ownable {
    struct Profile {
        string username;
        string ipfsHash; // Profile picture or metadata
        bool exists;
    }

    mapping(address => Profile) public profiles;
    mapping(string => address) public usernameToAddress;

    event ProfileUpdated(address indexed user, string username, string ipfsHash);

    constructor() Ownable(msg.sender) {}

    function setProfile(string memory _username, string memory _ipfsHash) external {
        require(bytes(_username).length > 0, "Username cannot be empty");
        
        // If updating username, check uniqueness
        if (keccak256(bytes(profiles[msg.sender].username)) != keccak256(bytes(_username))) {
            require(usernameToAddress[_username] == address(0), "Username already taken");
            
            // Clear old username mapping if it existed
            if (profiles[msg.sender].exists) {
                delete usernameToAddress[profiles[msg.sender].username];
            }
            
            usernameToAddress[_username] = msg.sender;
        }

        profiles[msg.sender] = Profile({
            username: _username,
            ipfsHash: _ipfsHash,
            exists: true
        });

        emit ProfileUpdated(msg.sender, _username, _ipfsHash);
    }

    function getProfile(address _user) external view returns (Profile memory) {
        return profiles[_user];
    }
}

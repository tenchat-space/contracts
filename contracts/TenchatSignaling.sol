// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TenchatSignaling {
    // Maps address to their public key (e.g., for E2EE)
    mapping(address => string) public publicKeys;

    event PublicKeyPublished(address indexed user, string publicKey);

    function publishPublicKey(string memory _publicKey) external {
        publicKeys[msg.sender] = _publicKey;
        emit PublicKeyPublished(msg.sender, _publicKey);
    }

    function getPublicKey(address _user) external view returns (string memory) {
        return publicKeys[_user];
    }
}

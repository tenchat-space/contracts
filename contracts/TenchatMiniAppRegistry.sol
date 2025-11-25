// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TenchatMiniAppRegistry is Ownable {
    struct MiniApp {
        string name;
        string description;
        string url; // IPFS hash or HTTPS url
        address developer;
        bool active;
    }

    mapping(uint256 => MiniApp) public apps;
    uint256 public appCount;

    event AppRegistered(uint256 indexed appId, string name, address indexed developer);
    event AppStatusChanged(uint256 indexed appId, bool active);

    constructor() Ownable(msg.sender) {}

    function registerApp(string memory _name, string memory _description, string memory _url) external {
        appCount++;
        apps[appCount] = MiniApp({
            name: _name,
            description: _description,
            url: _url,
            developer: msg.sender,
            active: true
        });

        emit AppRegistered(appCount, _name, msg.sender);
    }

    function toggleAppStatus(uint256 _appId) external {
        require(apps[_appId].developer == msg.sender || owner() == msg.sender, "Not authorized");
        apps[_appId].active = !apps[_appId].active;
        emit AppStatusChanged(_appId, apps[_appId].active);
    }

    function getApp(uint256 _appId) external view returns (MiniApp memory) {
        return apps[_appId];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TenchatSubscription is Ownable {
    IERC20 public tenchatToken;
    
    struct SubscriptionPlan {
        uint256 priceETH;
        uint256 priceToken;
        uint256 duration; // in seconds
        bool active;
    }

    mapping(uint256 => SubscriptionPlan) public plans;
    mapping(address => uint256) public userExpiry;
    uint256 public planCount;

    event SubscriptionPurchased(address indexed user, uint256 planId, uint256 expiry);
    event PlanCreated(uint256 planId, uint256 priceETH, uint256 priceToken, uint256 duration);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        tenchatToken = IERC20(_tokenAddress);
    }

    function createPlan(uint256 _priceETH, uint256 _priceToken, uint256 _duration) external onlyOwner {
        planCount++;
        plans[planCount] = SubscriptionPlan({
            priceETH: _priceETH,
            priceToken: _priceToken,
            duration: _duration,
            active: true
        });
        emit PlanCreated(planCount, _priceETH, _priceToken, _duration);
    }

    function subscribeWithETH(uint256 _planId) external payable {
        SubscriptionPlan memory plan = plans[_planId];
        require(plan.active, "Plan not active");
        require(msg.value >= plan.priceETH, "Insufficient ETH");

        _updateSubscription(msg.sender, plan.duration);
    }

    function subscribeWithToken(uint256 _planId) external {
        SubscriptionPlan memory plan = plans[_planId];
        require(plan.active, "Plan not active");
        
        require(tenchatToken.transferFrom(msg.sender, address(this), plan.priceToken), "Token transfer failed");

        _updateSubscription(msg.sender, plan.duration);
    }

    function _updateSubscription(address _user, uint256 _duration) internal {
        if (userExpiry[_user] < block.timestamp) {
            userExpiry[_user] = block.timestamp + _duration;
        } else {
            userExpiry[_user] += _duration;
        }
        emit SubscriptionPurchased(_user, 0, userExpiry[_user]); // 0 is placeholder for planId in this internal call context if needed, but event emits correctly
    }

    function isSubscribed(address _user) external view returns (bool) {
        return userExpiry[_user] > block.timestamp;
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawToken() external onlyOwner {
        uint256 balance = tenchatToken.balanceOf(address(this));
        tenchatToken.transfer(owner(), balance);
    }
}

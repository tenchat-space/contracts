// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TenchatPrediction is Ownable, ReentrancyGuard {
    IERC20 public bettingToken;

    enum MarketStatus { Open, Closed, Resolved }

    struct Market {
        uint256 id;
        string question;
        string[] options;
        uint256 endTime;
        MarketStatus status;
        uint256 winningOptionIndex;
        uint256 totalBets;
        mapping(uint256 => uint256) totalBetsByOption;
        // optionIndex => user => amount
        mapping(uint256 => mapping(address => uint256)) userBets;
    }

    uint256 public marketCount;
    mapping(uint256 => Market) public markets;

    event MarketCreated(uint256 indexed id, string question, string[] options, uint256 endTime);
    // Ten Protocol: Removed user address from event to preserve privacy
    event BetPlaced(uint256 indexed id, uint256 optionIndex, uint256 amount);
    event MarketResolved(uint256 indexed id, uint256 winningOptionIndex);
    event WinningsClaimed(uint256 indexed id, address indexed user, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        bettingToken = IERC20(_tokenAddress);
    }

    function createMarket(string memory _question, string[] memory _options, uint256 _duration) external onlyOwner {
        require(_options.length >= 2, "At least 2 options required");
        
        marketCount++;
        Market storage market = markets[marketCount];
        market.id = marketCount;
        market.question = _question;
        market.options = _options;
        market.endTime = block.timestamp + _duration;
        market.status = MarketStatus.Open;
        
        emit MarketCreated(marketCount, _question, _options, market.endTime);
    }

    function placeBet(uint256 _marketId, uint256 _optionIndex, uint256 _amount) external nonReentrant {
        Market storage market = markets[_marketId];
        require(market.status == MarketStatus.Open, "Market not open");
        require(block.timestamp < market.endTime, "Market expired");
        require(_optionIndex < market.options.length, "Invalid option");
        require(_amount > 0, "Amount must be > 0");

        require(bettingToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        market.userBets[_optionIndex][msg.sender] += _amount;
        market.totalBetsByOption[_optionIndex] += _amount;
        market.totalBets += _amount;

        emit BetPlaced(_marketId, _optionIndex, _amount);
    }

    function resolveMarket(uint256 _marketId, uint256 _winningOptionIndex) external onlyOwner {
        Market storage market = markets[_marketId];
        require(market.status != MarketStatus.Resolved, "Already resolved");
        require(_winningOptionIndex < market.options.length, "Invalid option");

        market.status = MarketStatus.Resolved;
        market.winningOptionIndex = _winningOptionIndex;

        emit MarketResolved(_marketId, _winningOptionIndex);
    }

    function claimWinnings(uint256 _marketId) external nonReentrant {
        Market storage market = markets[_marketId];
        require(market.status == MarketStatus.Resolved, "Market not resolved");

        uint256 winningOption = market.winningOptionIndex;
        uint256 userBet = market.userBets[winningOption][msg.sender];
        
        require(userBet > 0, "No winnings to claim");

        uint256 winningPool = market.totalBetsByOption[winningOption];
        uint256 totalPool = market.totalBets;

        // Reward = (UserBet / WinningPool) * TotalPool
        uint256 reward = (userBet * totalPool) / winningPool;

        market.userBets[winningOption][msg.sender] = 0; // Prevent re-entrancy

        require(bettingToken.transfer(msg.sender, reward), "Transfer failed");

        emit WinningsClaimed(_marketId, msg.sender, reward);
    }

    function getMarketOptions(uint256 _marketId) external view returns (string[] memory) {
        return markets[_marketId].options;
    }
}

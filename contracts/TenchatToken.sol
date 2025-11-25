// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TenchatToken is ERC20, Ownable {
    constructor() ERC20("Tenchat Token", "TENT") Ownable(msg.sender) {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    /**
     * @dev Overrides balanceOf to provide privacy on Ten Protocol.
     * Only the account holder can view their own balance.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        require(msg.sender == account, "TenchatToken: Balance is private");
        return super.balanceOf(account);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

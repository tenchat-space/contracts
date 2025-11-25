# Tenchat Smart Contracts

This directory contains the smart contracts for the Tenchat ecosystem.

## Contracts

- **TenchatToken (ERC20)**: Utility token for the ecosystem.
- **TenchatIdentity**: Maps user addresses to usernames and IPFS profile hashes.
- **TenchatSubscription**: Handles subscription payments in ETH or TENT.
- **TenchatSignaling**: Stores public keys for End-to-End Encryption (E2EE) in secret chats.
- **TenchatPrediction**: A prediction market engine.
- **TenchatMiniAppRegistry**: Registry for third-party mini-apps.

## Prediction Market Integration

The `TenchatPrediction` contract is designed to drive engagement and revenue through "speculation logic".

**How it fits into Tenchat:**
1.  **In-Chat Wagers**: Users in a group chat can create a prediction market (e.g., "Will Arsenal win today?") directly from the chat interface.
2.  **Mini-App Interface**: A dedicated "Predictions" mini-app can list all open markets, allowing users to browse and bet on global events.
3.  **Social Signals**: Winning bets can generate "reputation" or "badges" stored in the `TenchatIdentity` contract (future upgrade), displaying a user's prediction prowess on their profile.
4.  **Revenue**: The platform can take a small fee from the winning pool (configurable in future versions) to fund the ecosystem.

## Setup

1.  Install dependencies:
    ```bash
    npm install
    ```

2.  Compile contracts:
    ```bash
    npx hardhat compile
    ```

3.  Run tests:
    ```bash
    npx hardhat test
    ```

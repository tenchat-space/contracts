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

## Deployment

### Ten Testnet Deployment

To deploy to the official Ten Testnet:

1.  Create a `.env` file from `env.sample`:
    ```bash
    cp env.sample .env
    ```
2.  Add your wallet `PRIVATE_KEY` to `.env`.
3.  Run the deployment script:
    ```bash
    npx hardhat run scripts/deploy.ts --network ten
    ```

### Deployed Addresses (Local/Development)

These addresses are from a local deployment. Update this section after deploying to a live network.

| Contract | Address |
|----------|---------|
| **TenchatToken** | `0x75a0d486ce7730fA3752f91D3101997ABc942297` |
| **TenchatIdentity** | `0x5803335a6B851C0438281c7F37E95480f7fc586a` |
| **TenchatSignaling** | `0x6ff1561da1cce79765e2f541196894f9ef0bc170` |
| **TenchatMiniAppRegistry** | `0xb97A756bC016FaA099AFE4c9e2e8FA6E9F55c05a` |
| **TenchatPrediction** | `0xa71e7C9516b835b4A543568E4f5FC78d628FaC48` |
| **TenchatSubscription** | `0x33aE8331a2406EEc3A33483001aC5650DA2e0662` |

> **Note:** The Ten Testnet RPC URL is configured as `https://testnet.ten.xyz/v1/` with chain ID `8443`. If deployment fails, check the Ten Protocol documentation for the latest RPC details.

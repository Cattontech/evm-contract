# Catton AI Contracts

This repository contains smart contracts built for the EVM (Ethereum Virtual Machine) using Hardhat.

## Contracts Overview

### 1. Catton Token
- A standard ERC-20 token implementation.
- Provides basic token functionality such as minting, transferring, and burning tokens.
- Includes additional custom logic to align with project requirements.

### 2. Timelock
- A governance-focused contract to enforce a delay on executing critical transactions.
- Ensures operations such as upgrades or fund transfers are queued for a specific period before execution.
- Enhances security and trust by preventing instant execution of sensitive actions.

## Development and Testing
These contracts were developed and tested using the Hardhat framework to ensure reliability and compatibility with the EVM.

## Getting Started
To deploy or test these contracts, follow these steps:
1. Install dependencies:
   ```bash
   npm install

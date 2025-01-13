# Catton Contracts

This repository contains the implementation details for the **Catton AI Token Contract** and the **Timelock Contract**, designed to ensure secure token distribution and robust governance mechanisms.

---

## **Catton AI Token Contract**

### **Overview**
- **Token Name:** Catton AI  
- **Symbol:** CATON  
- **Standard:** LayerZero OFT (Omnichain Fungible Token)  
- **Supply:** Total supply minted at deployment  

### **Features**
- **Trading Restrictions:** Initially disabled, can be enabled by the owner.
- **Wallet Cap:** Enforces maximum token holdings per wallet.
- **Address Management:** Includes whitelisting and blacklisting capabilities.
- **Liquidity Pair Management:** Supports liquidity pair configuration.
- **Anti-Bot Protections:** Implements trading and holding restrictions for 10 minutes post-launch.
- **Cross-Chain Support:** Enables seamless cross-chain interactions via LayerZero.

### **Key Functions**
- **`enableTrading()`**: Enables trading.
- **`setMaxWalletCap(uint16 _cap)`**: Updates wallet cap.
- **`batchWhitelist(address[] calldata _addresses, bool _status)`**: Manages whitelist status.
- **`setRule(address[] calldata _tokenAddresses, uint256[] calldata _amounts, uint256[] calldata _maxHoldingAmounts)`**: Configures token holding rules.

### **Events**
- **`TradingEnabled(uint256 timestamp)`**: Triggered when trading is enabled.
- **`MaxWalletCap(uint16 cap)`**: Indicates a wallet cap update.
- **`AddressesWhitelisted(address[] addresses, bool status)`**: Logs whitelist updates.
---

## **Timelock Contract**

### **Overview**
The Timelock Contract ensures secure governance by introducing a delay for critical administrative actions, enabling a review period before execution.

### **Features**
- **Time-Delayed Execution:** Enforces a predefined delay for administrative actions.
- **Administrator Role:** Assigns trusted accounts to propose and execute changes.
- **Transparent Process:** All transactions must be queued, delayed, and then executed.

### **Key Functions**
- **`queueTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta)`**: Queues a transaction for delayed execution.
- **`executeTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta)`**: Executes a queued transaction after the delay.
- **`cancelTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta)`**: Cancels a queued transaction.

### **Events**
- **`TransactionQueued(address target, uint256 value, string signature, bytes data, uint256 eta)`**: Logs queued transactions.
- **`TransactionExecuted(address target, uint256 value, string signature, bytes data, uint256 eta)`**: Logs executed transactions.
- **`TransactionCanceled(address target, uint256 value, string signature, bytes data, uint256 eta)`**: Logs canceled transactions.

---

## **Testing Instructions**

### **Catton AI Token Contract**
- Validate trading enablement and restrictions.
- Test whitelisting functionality.
- Verify cross-chain transfer capability using LayerZero tools.

### **Timelock Contract**
- Test transaction queueing and delayed execution.
- Verify cancellation mechanisms for queued transactions.
- Ensure unauthorized actions are rejected.

---

## **Conclusion**
The combination of the Catton AI Token Contract and the Timelock Contract ensures secure, efficient, and transparent token operations. These contracts are tailored for robust governance and seamless cross-chain integrations.


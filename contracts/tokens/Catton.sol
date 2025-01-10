// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error InvalidLenght();
error ZeroAddress();
error MaxCapExceeded();
error MaxWalletCapExceeded();
error AddressIsNotWhitelisted();
error AddressIsBlacklisted();
error TradingAlreadyEnabled();
error TradingNotEnabled();
error MaxTokenAmount(address _token, uint256 _amount);

contract CATTON is OFT {
    uint16 public constant PRECISION = 10_000;

    bool public tradingEnabled;
    uint16 public max_wallet_cap;
    uint256 public launchTime;
    address public liquidityPair;

    bool public limited;
    address[] public tokenListAddresses;
    uint256[] public holdingAmounts; // amount token list
    uint256[] public maxHoldingAmount; // amount this token

    mapping(address token => bool isBlacklisted) public blacklistsAddresses;
    mapping(address account => bool isWhitelisted) public whitelistedAddresses;

    event MaxWalletCap(uint16 _max_wallet_cap);
    event TradingEnabled(uint256 _timestamp);
    event LiquidityPairSet(address indexed _pair);
    event AddressesWhitelisted(address[] _addresses, bool _isWhitelisted);
    event AddressesBlacklisted(address[] _addresses, bool _isBlacklisted);
    event Limited(bool _limited);
    event TokenListAddresses(address[] _tokenAddresses, uint256[] _holdingAmounts, uint256[] _maxHoldingAmount);

    constructor(
        address _lzEndpoint,
        uint256 _totalSupply
    ) OFT("Catton AI", "CATON", _lzEndpoint, _msgSender()) Ownable(_msgSender()) {
        max_wallet_cap = 2; // 0.02%
        limited = true;
        _mint(_msgSender(), _totalSupply);
    }

    function getMaxWalletAmount() public view returns (uint256) {
        return (totalSupply() * max_wallet_cap) / PRECISION;
    }

    // Can only be called once
    function enableTrading() external onlyOwner {
        if (tradingEnabled) revert TradingAlreadyEnabled();
        tradingEnabled = true;
        launchTime = block.timestamp;
        emit TradingEnabled(block.timestamp);
    }

    function setMaxWalletCap(uint16 _max_wallet_cap) external onlyOwner {
        if (_max_wallet_cap > PRECISION) {
            revert MaxCapExceeded();
        }
        max_wallet_cap = _max_wallet_cap;
        emit MaxWalletCap(_max_wallet_cap);
    }

    function setRule(
        bool _limited,
        address[] calldata _tokenAddresses,
        uint256[] calldata _amount,
        uint256[] calldata _maxHoldingAmount
    ) external onlyOwner {
        limited = _limited;
        emit Limited(limited);

        if (_tokenAddresses.length != _amount.length || _tokenAddresses.length != _maxHoldingAmount.length) {
            revert InvalidLenght();
        }

        tokenListAddresses = new address[](_tokenAddresses.length);
        holdingAmounts = new uint256[](_tokenAddresses.length);
        maxHoldingAmount = new uint256[](_tokenAddresses.length);

        for (uint256 i = 0; i < _tokenAddresses.length; ) {
            tokenListAddresses[i] = _tokenAddresses[i];
            holdingAmounts[i] = _amount[i];
            maxHoldingAmount[i] = _maxHoldingAmount[i];
            unchecked {
                i++;
            }
        }
        emit TokenListAddresses(_tokenAddresses, _amount, _maxHoldingAmount);
    }

    function setLimited(bool _limited) external onlyOwner {
        limited = _limited;
        emit Limited(limited);
    }

    function setLiquidityPair(address _pair) external onlyOwner {
        if (_pair == address(0)) revert ZeroAddress();
        liquidityPair = _pair;
        whitelistedAddresses[_pair] = true;
        emit LiquidityPairSet(_pair);
    }

    function batchWhitelist(address[] calldata _addresses, bool _isWhitelisted) external onlyOwner {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length; ) {
            address _address = _addresses[i];
            whitelistedAddresses[_address] = _isWhitelisted;
            unchecked {
                i++;
            }
        }
        emit AddressesWhitelisted(_addresses, _isWhitelisted);
    }

    function batchBlacklist(address[] calldata _addresses, bool _isBlacklisted) external onlyOwner {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length; ) {
            address _address = _addresses[i];
            blacklistsAddresses[_address] = _isBlacklisted;
            unchecked {
                i++;
            }
        }
        emit AddressesBlacklisted(_addresses, _isBlacklisted);
    }

    function _update(address _from, address _to, uint256 _amount) internal override {
        bool isFromBlacklisted = blacklistsAddresses[_from];

        // Block blacklisted users
        if (isFromBlacklisted) {
            revert AddressIsBlacklisted();
        }

        bool isTradingEnabled = tradingEnabled;
        bool isFromWhitelisted = whitelistedAddresses[_from];
        bool isToWhitelisted = whitelistedAddresses[_to];

        address _liquidityPair = liquidityPair;
        bool isFromLiquidityPair = _from == _liquidityPair;
        bool isToLiquidityPair = _to == _liquidityPair;
        address _owner = owner();
        bool isOwner = _from == _owner || _to == _owner;

        // Sniper trap
        if (!isTradingEnabled && isFromLiquidityPair && !isOwner) {
            revert TradingNotEnabled();
        }
        /*
         * Anti-bot/whale protection for the first 10 minutes after launch:
         * 1. Only whitelisted addresses can transfer tokens
         * 2. Maximum wallet cap of 0.1% of total supply is enforced
         */

        if (isTradingEnabled && block.timestamp < launchTime + 10 minutes) {
            bool isWhitelisted = isToWhitelisted || isFromWhitelisted;

            // Block non-whitelisted users from buying via the liquidity pair
            if (isFromLiquidityPair && !isToWhitelisted) {
                revert AddressIsNotWhitelisted();
            }

            // Block non-whitelisted users from selling to the liquidity pair
            if (isToLiquidityPair && !isFromWhitelisted) {
                revert AddressIsNotWhitelisted();
            }

            // If the address is not whitelisted and not the owner, revert
            if (!isWhitelisted && !isOwner) {
                revert AddressIsNotWhitelisted();
            }

            // If the receipt address is not the liquidity pair, check the max wallet cap
            if (!isToLiquidityPair && balanceOf(_to) + _amount > getMaxWalletAmount()) {
                revert MaxWalletCapExceeded();
            }
        }

        /*
         * Token holders on the list will be restricted.
         */

        if (limited && isFromLiquidityPair) {
            for (uint256 i = 0; i < tokenListAddresses.length; ) {
                address recipient = _to; // Fix stack too deep
                address tokenAddress = tokenListAddresses[i];
                uint256 tokenBalance = ERC20(tokenAddress).balanceOf(recipient);

                if (super.balanceOf(recipient) + _amount >= maxHoldingAmount[i] && tokenBalance >= holdingAmounts[i]) {
                    revert MaxTokenAmount(tokenAddress, tokenBalance);
                }

                unchecked {
                    i++;
                }
            }
        }

        super._update(_from, _to, _amount);
    }
}

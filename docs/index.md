# UDOT

### uniswapPair

```solidity
address uniswapPair
```

### feeWallet

```solidity
address feeWallet
```

### cap

```solidity
uint256 cap
```

### sellTax

```solidity
uint256 sellTax
```

### buyTax

```solidity
uint256 buyTax
```

### whitelisted

```solidity
mapping(address => bool) whitelisted
```

### userWhiteList

```solidity
event userWhiteList(address _user, bool _status)
```

### changeFeeWallet

```solidity
event changeFeeWallet(address _lastFeeWallet, address _newFeeWallet)
```

### changeSellTax

```solidity
event changeSellTax(uint256 _lastTax, uint256 _newTax)
```

### changeBuyTax

```solidity
event changeBuyTax(uint256 _lastTax, uint256 _newTax)
```

### constructor

```solidity
constructor() public
```

### mint

```solidity
function mint() external payable
```

Allows the user to mine UDOT in exchange for MATIC, each UDOT will be backed 1:1 by MATIC

### burn

```solidity
function burn(uint256 _amount) external
```

Allows the user to burn UDOT in exchange for MATIC. For each UDOT that is burned, the user will 
        receive the same value in MATIC.

### pause

```solidity
function pause() external
```

_Owner can pause token transfer_

### unpause

```solidity
function unpause() external
```

_Owner can unpause token transfer_

### whiteList

```solidity
function whiteList(address _user, bool _isWhitelisted) external
```

_The owner can add a user to the white list and thus not pay transfer taxes_

### setFeeWallet

```solidity
function setFeeWallet(address _feeWallet) external
```

_The owner can establish which will be the wallet that receives all the fees_

### setSellTax

```solidity
function setSellTax(uint256 _taxPercent) external
```

_The owner can establish what the sales tax will be_

### setBuyTax

```solidity
function setBuyTax(uint256 _taxPercent) external
```

_The owner can establish what the buy tax will be_

### rescueStuckToken

```solidity
function rescueStuckToken(address _token, address _to) external
```

_The owner can recover tokens stuck in the contract (but not MATIC)_

### _mint

```solidity
function _mint(address account, uint256 amount) internal
```

_Check that you cannot mint more than 1M tokens_

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal
```

_overwrite the transfer function to be able to take the taxes_


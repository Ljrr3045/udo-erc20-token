//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract UdoToken is ERC20, ERC20Burnable, Ownable, Pausable {
    using SafeMath for uint256;

    uint256 private _cap;

    bool public isAntiBot;
    uint256 public maxBuy;
    uint256 public maxSell;
    uint256 public antiBotStart; 
    uint256 public antiBotEnd;
    uint256 public PER_DIVI;
    uint256 public sellTax;
    uint256 public buyTax;
    address public feeWallet;

//Mappings

    mapping(address => bool) public lps;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public whitelisted;

//Events

    event SetAntiBot(bool _IsAntiBot);
    event SetMaxSell(uint256 _MaxSell);
    event SetMaxBuy(uint256 _MaxBuy);
    event SetAntiBotTime(uint256 _antiBotStart, uint256 _antiBotEnd);
    event SetLiquidPair(address _LP, bool _Status);

//Constructor

    constructor() ERC20("Universidad de Oriente", "UDOT") {

        maxBuy = 5000 * 10**decimals();
        maxSell = 5000 * 10**decimals();

        PER_DIVI = 10000;
        sellTax = 400; // 4%
        buyTax = 0; // 0%

        uint256 num = 1000000000 * 10**decimals();
        _cap = num;
        _mint(msg.sender, num);
    }

//View Functions

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

//Only Owner Functions

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function setAntiBot(bool _isEnabled) external onlyOwner {
        isAntiBot = _isEnabled;
        emit SetAntiBot(_isEnabled);
    }

    function blacklist(address _user, bool _isBlacklisted) external onlyOwner {
        blacklisted[_user] = _isBlacklisted;
    }

    function setMaxSell(uint256 _maxSell) external onlyOwner {
        maxSell = _maxSell;
        emit SetMaxSell(_maxSell);
    }

    function setMaxBuy(uint256 _maxBuy) external onlyOwner {
        maxBuy = _maxBuy;
        emit SetMaxBuy(_maxBuy);
    }

    function setLiquidPair(address _lp, bool _status) external onlyOwner {
        require(address(0) != _lp,"_lp zero address");
        lps[_lp] = _status;
        emit SetLiquidPair(_lp, _status);
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        feeWallet = _feeWallet;
    }

    function setSellTax(uint256 _taxPercent) external onlyOwner {
        sellTax = _taxPercent;
    }

    function setBuyTax(uint256 _taxPercent) external onlyOwner {
        buyTax = _taxPercent;
    }

    function rescueStuckToken(address _token, address _to) external onlyOwner {
        uint256 _amount = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(_to, _amount);
    }

    function setAntiBotTime(
        uint256 _antiBotStart,
        uint256 _antiBotEnd
        ) external onlyOwner {
        antiBotStart = _antiBotStart;
        antiBotEnd = _antiBotEnd;
        emit SetAntiBotTime(_antiBotEnd, _antiBotEnd);
    }

//Override Functions

    function _mint(address account, uint256 amount) internal override {
        require(ERC20.totalSupply() + amount <= cap(), 'Cap exceeded');
        super._mint(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(!blacklisted[from] && !blacklisted[to], "Transfer blacklisted");
        if (isAntiBot == true && antiBotStart < block.timestamp && block.timestamp < antiBotEnd ) {
            antiBot(from, to, amount);
        }

        super._beforeTokenTransfer(from, to, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused{
         if (lps[from] == true && !whitelisted[to] && buyTax > 0 && feeWallet != address(0)) {
            uint256 fee = amount.mul(buyTax).div(PER_DIVI);
            uint256 transferA = amount.sub(fee);
            super._transfer(from, feeWallet, fee);
            super._transfer(from, to, transferA);
        } 
        else if (lps[to] == true && !whitelisted[from] && sellTax > 0 && feeWallet != address(0)) {
            uint256 fee = amount.mul(sellTax).div(PER_DIVI);
            uint256 transferA = amount.sub(fee);
            super._transfer(from, feeWallet, fee);
            super._transfer(from, to, transferA);
        }
        else {
            super._transfer(from, to, amount);
        }
    }

//Internal Functions

    function antiBot(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal view {
        if (lps[_sender] == true && !whitelisted[_recipient]) {
        	if (_amount > maxBuy) {
          	revert("Anti bot buy");
          }
        }

        if (lps[_recipient] == true  && !whitelisted[_sender]) {
            if (_amount > maxSell) {
                revert("Anti bot sell");
            }
        }

    }
}
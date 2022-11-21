//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

contract UDOT is ERC20, Ownable, Pausable {
    using SafeMath for uint256;

    address public uniswapPair;
    address public feeWallet;

    uint256 public cap;
    uint256 public maxBuy;
    uint256 public maxSell;
    uint256 public sellTax;
    uint256 public buyTax;

//Mappings

    mapping(address => bool) public whitelisted;

//Events

    event SetMaxSell(uint256 _MaxSell);
    event SetMaxBuy(uint256 _MaxBuy);
    event userWhiteList(address _user, bool _status);
    event changeFeeWallet(address _lastFeeWallet, address _newFeeWallet);
    event changeSellTax(uint256 _lastTax, uint256 _newTax);
    event changeBuyTax(uint256 _lastTax, uint256 _newTax);

//Constructor

    constructor() ERC20("Universidad de Oriente", "UDOT") {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);

        feeWallet = msg.sender;
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        maxBuy = 5000 * 10**decimals();
        maxSell = 5000 * 10**decimals();

        sellTax = 200; // 2%
        buyTax = 200; // 2%

        cap = 1000000 * 10**decimals();
    }

//Useful Functions

    function mint() external payable{
        require(msg.value > 0,"UDOT: The amount must be greater than 0");

        _mint(_msgSender(), msg.value);
    }

    function burn(uint256 _amount) external {
        require(_amount > 0,"UDOT: The amount must be greater than 0");

        _burn(_msgSender(), _amount);

        (bool _success,) = payable(_msgSender()).call{ value: _amount }("");
        require(_success, "UDOT: Error returning funds");
    }

//Only Owner Functions

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function whiteList(address _user, bool _isWhitelisted) external onlyOwner {
        require(address(0) != _user,"UDOT: User is zero address");

        whitelisted[_user] = _isWhitelisted;
        emit userWhiteList(_user, _isWhitelisted);
    }

    function setMaxBuy(uint256 _maxBuy) external onlyOwner {
        require(_maxBuy >= (1 * 10**decimals()),"UDOT: The amount must be greater than 1 MATIC");

        maxBuy = _maxBuy;
        emit SetMaxBuy(_maxBuy);
    }

    function setMaxSell(uint256 _maxSell) external onlyOwner {
        require(_maxSell >= (1 * 10**decimals()),"UDOT: The amount must be greater than 1 MATIC");

        maxSell = _maxSell;
        emit SetMaxSell(_maxSell);
    }

    function setFeeWallet(address _feeWallet) external onlyOwner {
        require(address(0) != _feeWallet,"UDOT: FeeWallet is zero address");

        emit changeFeeWallet(feeWallet, _feeWallet);
        feeWallet = _feeWallet;
    }

    function setSellTax(uint256 _taxPercent) external onlyOwner {
        require((_taxPercent > 0) && (_taxPercent < 2000),"UDOT: Taxes cannot be higher than 20%");

        emit changeSellTax(sellTax, _taxPercent);
        sellTax = _taxPercent;
    }

    function setBuyTax(uint256 _taxPercent) external onlyOwner {
        require((_taxPercent > 0) && (_taxPercent < 2000),"UDOT: Taxes cannot be higher than 20%");

        emit changeBuyTax(buyTax, _taxPercent);
        buyTax = _taxPercent;
    }

    function rescueStuckToken(address _token, address _to) external onlyOwner {

        uint256 _amount = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(_to, _amount);
    }

//Override Functions

    function _mint(address account, uint256 amount) internal override {
        require((ERC20.totalSupply() + amount) <= cap, 'UDOT: Cap exceeded');

        super._mint(account, amount);
    }

    function _transfer( address from, address to, uint256 amount ) internal override whenNotPaused{

        if ((!whitelisted[to]) && (buyTax > 0) && (feeWallet != address(0))) {

            uint256 fee = amount.mul(buyTax).div(10000);
            uint256 _newAmount = amount.sub(fee);
            super._transfer(from, feeWallet, fee);
            super._transfer(from, to, _newAmount);

        } else if ((!whitelisted[from]) && (sellTax > 0) && (feeWallet != address(0))) {

            uint256 fee = amount.mul(sellTax).div(10000);
            uint256 _newAmount = amount.sub(fee);
            super._transfer(from, feeWallet, fee);
            super._transfer(from, to, _newAmount);

        } else {

            super._transfer(from, to, amount);
        }
    }
}
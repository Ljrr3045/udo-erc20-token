//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
    @title UDOT Contract
    @author ljrr3045
    @notice ERC20 contract to function as a utility token for the Univerdidad de Oriente.
    @dev Each minted token will be backed 1:1 by MATIC.
*/

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router.sol";

contract UDOT is ERC20, Ownable, Pausable {
    using SafeMath for uint256;

    address public uniswapPair;
    address public feeWallet;

    uint256 public cap;
    uint256 public sellTax;
    uint256 public buyTax;

//Mappings

    mapping(address => bool) public whitelisted;

//Events

    event userWhiteList(address _user, bool _status);
    event changeFeeWallet(address _lastFeeWallet, address _newFeeWallet);
    event changeSellTax(uint256 _lastTax, uint256 _newTax);
    event changeBuyTax(uint256 _lastTax, uint256 _newTax);

//Constructor

    constructor() ERC20("Universidad de Oriente", "UDOT") {

        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        feeWallet = msg.sender;
        whitelisted[feeWallet] = true;
        
        sellTax = 200; // 2%
        buyTax = 200; // 2%

        cap = 1000000 * 10**decimals();
    }

//Useful Functions

    /**
        @notice Allows the user to mine UDOT in exchange for MATIC, each UDOT will be backed 1:1 by MATIC
    */
    function mint() external payable{
        require(msg.value > 0,"UDOT: The amount must be greater than 0");

        _mint(_msgSender(), msg.value);
    }

    /**
        @notice Allows the user to burn UDOT in exchange for MATIC. For each UDOT that is burned, the user will 
        receive the same value in MATIC.
    */
    function burn(uint256 _amount) external {
        require(_amount > 0,"UDOT: The amount must be greater than 0");

        _burn(_msgSender(), _amount);

        (bool _success,) = payable(_msgSender()).call{ value: _amount }("");
        require(_success, "UDOT: Error returning funds");
    }

//Only Owner Functions

    ///@dev Owner can pause token transfer
    function pause() external onlyOwner {
        _pause();
    }

    ///@dev Owner can unpause token transfer
    function unpause() external onlyOwner {
        _unpause();
    }

    ///@dev The owner can add a user to the white list and thus not pay transfer taxes
    function whiteList(address _user, bool _isWhitelisted) external onlyOwner {
        require(address(0) != _user,"UDOT: User is zero address");

        whitelisted[_user] = _isWhitelisted;
        emit userWhiteList(_user, _isWhitelisted);
    }

    ///@dev The owner can establish which will be the wallet that receives all the fees
    function setFeeWallet(address _feeWallet) external onlyOwner {
        require(address(0) != _feeWallet,"UDOT: FeeWallet is zero address");

        emit changeFeeWallet(feeWallet, _feeWallet);
        feeWallet = _feeWallet;
    }

    ///@dev The owner can establish what the sales tax will be
    function setSellTax(uint256 _taxPercent) external onlyOwner {
        require((_taxPercent > 0) && (_taxPercent < 2000),"UDOT: Taxes cannot be higher than 20%");

        emit changeSellTax(sellTax, _taxPercent);
        sellTax = _taxPercent;
    }

    ///@dev The owner can establish what the buy tax will be
    function setBuyTax(uint256 _taxPercent) external onlyOwner {
        require((_taxPercent > 0) && (_taxPercent < 2000),"UDOT: Taxes cannot be higher than 20%");

        emit changeBuyTax(buyTax, _taxPercent);
        buyTax = _taxPercent;
    }

    ///@dev The owner can recover tokens stuck in the contract (but not MATIC)
    function rescueStuckToken(address _token, address _to) external onlyOwner {

        uint256 _amount = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(_to, _amount);
    }

//Override Functions

    ///@dev Check that you cannot mint more than 1M tokens
    function _mint(address account, uint256 amount) internal override {
        require((ERC20.totalSupply() + amount) <= cap, 'UDOT: Maximum capital exceeded');

        super._mint(account, amount);
    }

    ///@dev overwrite the transfer function to be able to take the taxes
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
pragma solidity ^0.4.24;

import './LEAD.sol';
import './ownership/Ownable.sol';

contract PreSale is Ownable {
    
    using SafeMath for uint;
    uint256 public startTime;
    uint256 public endTime;
    uint256 constant dec = 10 ** 8;
    uint256 public tokensToSale = 300000000 * 10 ** 8;
    // address where funds are collected
    address public wallet;
    // one token per one rate
    uint256 public rate = 800;
    LEAD public token;
    // Amount of raised money in wei
    uint256 public weiRaised;
    uint256 public minTokensToSale = 200 * dec;

    uint256 timeBonus1 = 30;
    uint256 timeBonus2 = 20;
    uint256 timeBonus3 = 10;
    uint256 timeStaticBonus = 0;

    // Round bonuses
    uint256 bonus1 = 20;
    uint256 bonus2 = 30;
    uint256 bonus3 = 40;
    uint256 bonus4 = 50;

    // Amount bonuses
    uint256 amount1 = 0;
    uint256 amount2 = 3 * dec;
    uint256 amount3 = 4 * dec;
    uint256 amount4 = 5 * dec;


    constructor(
        address _token,
        uint256 _startTime,
        uint256 _endTime,
        address _wallet) public {
        require(_token != address(0));
        require(_endTime > _startTime);
        require(_wallet != address(0));
        token = LEAD(_token);
        startTime = _startTime;
        endTime = _endTime;
        wallet = _wallet;
    }

    modifier saleIsOn() {
        uint tokenSupply = token.totalSupply();
        require(now > startTime && now < endTime);
        require(tokenSupply <= tokensToSale);
        _;
    }

    function setStaticBonus(
        uint256 _newStaticBonus) onlyOwner public {
        timeStaticBonus = _newStaticBonus;
    }

    function setMinTokensToSale(
        uint256 _newMinTokensToSale) onlyOwner public {
        minTokensToSale = _newMinTokensToSale;
    }

    function setAmount(
        uint256 _newAmount1,
        uint256 _newAmount2,
        uint256 _newAmount3,
        uint256 _newAmount4) onlyOwner public {
        amount1 = _newAmount1;
        amount2 = _newAmount2;
        amount3 = _newAmount3;
        amount4 = _newAmount4;
    }

    function setBonuses(
        uint256 _newBonus1,
        uint256 _newBonus2,
        uint256 _newBonus3,
        uint256 _newBonus4) onlyOwner public {
        bonus1 = _newBonus1;
        bonus2 = _newBonus2;
        bonus3 = _newBonus3;
        bonus4 = _newBonus4;
    }

    function getTimeBonus() public view returns (uint256) {
        if(now < startTime + 1 days) { // Round X
            return timeBonus1;
        } else if(now >= startTime + 1 days && now < startTime + 16 days) { // Round 1
            return timeBonus2;
        } else if(now >= startTime + 16 days && now < startTime + 15 days) { // Round 2
            return timeBonus3;
        } else if(now >= startTime + 15 days && now < endTime) { // Round 3
            return timeStaticBonus;
        }
    }

    function getBonus(uint256 _value) internal view returns (uint256) {
        if(_value >= amount1 && _value < amount2) { 
            return bonus1;
        } else if(_value >= amount2 && _value < amount3) {
            return bonus2;
        } else if(_value >= amount3 && _value < amount4) {
            return bonus3;
        } else if(_value >= amount4) {
            return bonus4;
        }
    }

    function setEndTime(uint256 _newEndTime) onlyOwner public {
        require(now < _newEndTime);
        endTime = _newEndTime;
    }

    function setRate(uint256 _newRate) public onlyOwner {
        rate = _newRate;
    }

    function setTeamAddress(address _newWallet) onlyOwner public {
        require(_newWallet != address(0));
        wallet = _newWallet;
    }

    /**
    * events for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event TokenPartners(address indexed purchaser, address indexed beneficiary, uint256 amount);

    function buyTokens(address beneficiary) saleIsOn public payable {
        require(beneficiary != address(0));
        uint256 weiAmount = (msg.value).div(10 ** 10);
        uint256 all = 100;
        uint256 timeBonusNow = getTimeBonus();
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        require(tokens >= minTokensToSale);
        uint256 bonusNow = getBonus(tokens);
        uint256 tokensSumBonus = tokens.add(tokens.mul(timeBonusNow).div(all));
        tokensSumBonus = tokensSumBonus.add(tokens.mul(bonusNow).div(all));
        require(tokensToSale > tokensSumBonus.add(token.totalSupply()));
        weiRaised = weiRaised.add(msg.value);
        token.mint(beneficiary, tokensSumBonus);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokensSumBonus);

        wallet.transfer(msg.value);
    }

    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }

    // @return true if tokensale event has ended
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }

    function kill() onlyOwner public { selfdestruct(owner); }
    
}
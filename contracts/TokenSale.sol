pragma solidity ^0.4.24;

import './LEAD.sol';
import './ownership/Ownable.sol';

contract TokenSale is Ownable {
    
    using SafeMath for uint;
    uint256 public startTime;
    uint256 public endTime;
    uint256 constant dec = 10 ** 8;
    uint256 public tokensToSale = 500000000 * 10 ** 8;
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

    // Round 1 bonuses
    uint256 bonus1_1 = 15;
    uint256 bonus1_2 = 25;
    uint256 bonus1_3 = 35;
    uint256 bonus1_4 = 45;

    // Round 2 bonuses
    uint256 bonus2_1 = 10;
    uint256 bonus2_2 = 20;
    uint256 bonus2_3 = 30;
    uint256 bonus2_4 = 40;

    // Round 3 bonuses
    uint256 bonus3_1 = 10;
    uint256 bonus3_2 = 15;
    uint256 bonus3_3 = 25;
    uint256 bonus3_4 = 35;

    // Round 4 bonuses
    uint256 bonus4_1 = 5;
    uint256 bonus4_2 = 10;
    uint256 bonus4_3 = 20;
    uint256 bonus4_4 = 30;

    // Amount bonuses
    uint256 amount1 = 0;
    uint256 amount2 = 2 * dec;
    uint256 amount3 = 3 * dec;
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


    function getBonus(uint256 _value) internal view returns (uint256) {
        if(_value >= amount1 && _value < amount2) { 
            return bonus1_1;
        } else if(_value >= amount2 && _value < amount3) {
            return bonus1_2;
        } else if(_value >= amount3 && _value < amount4) {
            return bonus1_3;
        } else if(_value >= amount4) {
            return bonus1_4;
        }
    }

    function getBonus2(uint256 _value) internal view returns (uint256) {
        if(_value >= amount1 && _value < amount2) { 
            return bonus2_1;
        } else if(_value >= amount2 && _value < amount3) {
            return bonus2_2;
        } else if(_value >= amount3 && _value < amount4) {
            return bonus2_3;
        } else if(_value >= amount4) {
            return bonus2_4;
        }
    }

    function getBonus3(uint256 _value) internal view returns (uint256) {
        if(_value >= amount1 && _value < amount2) { 
            return bonus3_1;
        } else if(_value >= amount2 && _value < amount3) {
            return bonus3_2;
        } else if(_value >= amount3 && _value < amount4) {
            return bonus3_3;
        } else if(_value >= amount4) {
            return bonus3_4;
        }
    }

    function getBonus4(uint256 _value) internal view returns (uint256) {
        if(_value >= amount1 && _value < amount2) { 
            return bonus4_1;
        } else if(_value >= amount2 && _value < amount3) {
            return bonus4_2;
        } else if(_value >= amount3 && _value < amount4) {
            return bonus4_3;
        } else if(_value >= amount4) {
            return bonus4_4;
        }
    }

    function getTimeBonus(uint256 _value) public view returns (uint256) {
        if(now < startTime + 61 days) { // Round 1
            return getBonus(_value);
        } else if(now >= startTime + 61 days && now < startTime + 120 days) { // Round 2
            return getBonus2(_value);
        } else if(now >= startTime + 120 days && now < startTime + 181 days) { // Round 3
            return getBonus3(_value);
        } else if(now >= startTime + 181 days && now < endTime) { // Round 4
            return getBonus4(_value);
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
        uint256 timeBonusNow = getTimeBonus(weiAmount);
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        require(tokens >= minTokensToSale);
        uint256 tokensSumBonus = tokens.add(tokens.mul(timeBonusNow).div(all));
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
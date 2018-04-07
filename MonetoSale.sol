pragma solidity ^0.4.11;

import "./MONETO.sol";

contract MonetoSale {
    MONETO public token;

    address public beneficiary;
    address public alfatokenteam;
    uint public alfatokenFee;
    
    uint public amountRaised;
    uint public tokenSaled;
    
    uint public preSaleStart;
    uint public preSaleEnd;
    uint public saleStart;
    uint public saleEnd;
    
    Stages public stage;
    
    enum Stages {
        Deployed,
        SetUp,
        Ended,
        Canceled
    }
    
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    modifier isOwner() {
        require(msg.sender == beneficiary);
        _;
    }

    function MonetoSale(address _beneficiary, address _alfatokenteam) public {
        beneficiary = _beneficiary;
        alfatokenteam = _alfatokenteam;
        alfatokenFee = 7000000000000000000;

        stage = Stages.Deployed;
    }

    function setup(address _token) public isOwner atStage(Stages.Deployed) {
        require(_token != 0x0);
        token = MONETO(_token);

        preSaleStart = 1523318400; // 10 April 2018, 00:00:00 GMT
        preSaleEnd = 1525910399; // 9 May 2018, 23:59:59 GMT
        saleStart = 1528588800; // 10 June 2018,00:00:00 GMT
        saleEnd = 1531180799; // 9 July 2018, 23:59:59 GMT

        stage = Stages.SetUp;
    }

    function () payable public {
        require((now >= preSaleStart && now <= preSaleEnd) || (now >= saleStart && now <= preSaleEnd));
        
        uint amount = msg.value;
        amountRaised += amount;

        uint tokenAmount = amount * getPrice();
        require(tokenAmount > getMinimumAmount());
        uint allTokens = tokenAmount + getBonus(tokenAmount);
        token.transfer(msg.sender, allTokens);
        tokenSaled += allTokens;
    }

    function transferETH(address _to, uint _amount) public isOwner {
        require(_amount <= this.balance - alfatokenFee);
        require(now < saleStart || stage == Stages.Ended);
        
        _to.transfer(_amount);
    }

    function transferFee(address _to, uint _amount) public {
        require(msg.sender == alfatokenteam);
        require(_amount <= alfatokenFee);

        _to.transfer(_amount);
        alfatokenFee -= _amount;
    }

    function endSale(address _to) public isOwner {
        require(amountRaised >= 2500 ether);

        token.transfer(_to, tokenSaled*30/100);
        token.burn(token.balanceOf(address(this)));

        stage = Stages.Ended;
    }

    function cancelSale() public isOwner {
        require(amountRaised < 2500 ether);
        require(now > saleStart);

        stage = Stages.Canceled;
    }

    function getBonus(uint amount) public constant returns (uint) {
        if (now >= preSaleStart && now <= preSaleEnd) {
            uint w = now - preSaleStart;
            if (w <= 1 weeks) {
                return amount*30/100;
            }
            if (w > 1 weeks && w <= 2 weeks) {
                return amount*15/100;
            }
            if (w > 2 weeks && w <= 3 weeks) {
                return amount*5/100;
            }
            return 0;
        }
        if (now >= saleStart && now <= saleEnd) {
            uint w2 = now - saleStart;
            if (w2 <= 1 weeks) {
                return amount*10/100;
            }
            if (w2 > 1 weeks && w <= 2 weeks) {
                return amount*5/100;
            }
            if (w2 > 2 weeks && w <= 3 weeks) {
                return amount*3/100;
            }
            return 0;
        }
        return 0;
    }

    function getPrice() public constant returns (uint) {
        if (now >= preSaleStart && now <= preSaleEnd) {
            return 1250;
        }
        if (now >= saleStart && now <= saleEnd) {
            return 1000;
        }
        return 0;
    }

    function getMinimumAmount() public constant returns (uint) {
        if (now >= preSaleStart && now <= preSaleEnd) {
            return 50000000000000000000;
        }
        if (now >= saleStart && now <= saleEnd) {
            return 1000000000000000000;
        }
        return 0;
    }
}

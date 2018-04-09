pragma solidity ^0.4.11;

import "./Moneto.sol";

contract MonetoSale {
    Moneto public token;

    address public beneficiary;
    address public alfatokenteam;
    uint public alfatokenFee;
    
    uint public amountRaised;
    uint public tokenSold;
    
    uint public preSaleStart;
    uint public preSaleEnd;
    uint public saleStart;
    uint public saleEnd;

    mapping (address => uint) public icoBuyers;
    
    Stages public stage;
    
    enum Stages {
        Deployed,
        Ready,
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
        alfatokenFee = 7 ether;

        stage = Stages.Deployed;
    }

    function setup(address _token) public isOwner atStage(Stages.Deployed) {
        require(_token != 0x0);
        token = Moneto(_token);

        preSaleStart = 1523952000; // 17 April 2018, 08:00:00 GMT
        preSaleEnd = 1526543999; // 17 May 2018, 07:59:59 GMT
        saleStart = 1528617600; // 10 June 2018,08:00:00 GMT
        saleEnd = 1531209599; // 10 July 2018, 07:59:59 GMT

        stage = Stages.Ready;
    }

    function () payable public atStage(Stages.Ready) {
        require((now >= preSaleStart && now <= preSaleEnd) || (now >= saleStart && now <= saleEnd));

        uint amount = msg.value;
        amountRaised += amount;

        if (now >= saleStart && now <= saleEnd) {
            assert(icoBuyers[msg.sender] + msg.value >= msg.value);
            icoBuyers[msg.sender] += amount;
        }
        
        uint tokenAmount = amount * getPrice();
        require(tokenAmount > getMinimumAmount());
        uint allTokens = tokenAmount + getBonus(tokenAmount);
        tokenSold += allTokens;

        if (now >= preSaleStart && now <= preSaleEnd) {
            require(tokenSold <= 2531250 * 10**18);
        }
        if (now >= saleStart && now <= saleEnd) {
            require(tokenSold <= 300312502 * 10**17);
        }

        token.transfer(msg.sender, allTokens);
    }

    function transferEter(address _to, uint _amount) public isOwner {
        require(_amount <= this.balance - alfatokenFee);
        require(now < saleStart || stage == Stages.Ended);
        
        _to.transfer(_amount);
    }

    function transferFee(address _to, uint _amount) public {
        require(msg.sender == alfatokenteam);
        require(_amount <= alfatokenFee);

        alfatokenFee -= _amount;
        _to.transfer(_amount);
    }

    function endSale(address _to) public isOwner {
        require(amountRaised >= 2500 ether);

        token.transfer(_to, tokenSold*3/7);
        token.burn(token.balanceOf(address(this)));

        stage = Stages.Ended;
    }

    function cancelSale() public {
        require(amountRaised < 2500 ether);
        require(now > saleEnd);

        stage = Stages.Canceled;
    }

    function takeEterBack() public atStage(Stages.Canceled) returns (bool) {
        return proxyTakeEterBack(msg.sender);
    }

    function proxyTakeEterBack(address receiverAddress) public atStage(Stages.Canceled) returns (bool) {
        require(receiverAddress != 0x0);
        
        if (icoBuyers[receiverAddress] == 0) {
            return false;
        }

        uint amount = icoBuyers[receiverAddress];
        icoBuyers[receiverAddress] = 0;
        receiverAddress.transfer(amount);

        assert(icoBuyers[receiverAddress] == 0);
        return true;
    }

    function getBonus(uint amount) public view returns (uint) {
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

    function getPrice() public view returns (uint) {
        if (now >= preSaleStart && now <= preSaleEnd) {
            return 1250;
        }
        if (now >= saleStart && now <= saleEnd) {
            return 1000;
        }
        return 0;
    }

    function getMinimumAmount() public view returns (uint) {
        if (now >= preSaleStart && now <= preSaleEnd) {
            return 10 * 10**18;
        }
        if (now >= saleStart && now <= saleEnd) {
            return 1 * 10**18;
        }
        return 0;
    }
}

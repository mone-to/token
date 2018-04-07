pragma solidity ^0.4.11;

import "./MONETO.sol";

contract MonetoSale {
    MONETO public token;
    address public beneficiary;
    address public alfatokenteam;
    
    uint public amountRaised;
       
    uint public minSaleAmount;
    uint public alfatokenFee;
    
    uint public startTime;
    uint public endTime;
    uint public startBlock;
    
    Stages public stage;
    
    enum Stages {
        Deployed,
        SetUp,
        PreSaleStarted,
        PreSaleEnded,
        SaleStarted,
        SaleEnded,
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
        minSaleAmount = 1000000000000000000;
        alfatokenFee = 7000000000000000000;

        stage = Stages.Deployed;
    }

    function setup(address _token) public isOwner atStage(Stages.Deployed) {
        require(_token != 0x0);
        token = MONETO(_token);

        stage = Stages.SetUp;
    }

    function () payable public {
        uint amount = msg.value;
        uint tokenAmount = amount * getPrice();
        require(tokenAmount > minSaleAmount);
        amountRaised += amount;
        token.transfer(msg.sender, tokenAmount + getBonus(tokenAmount));
    }

    function transferETH(address _to, uint _amount) public {
        require(msg.sender == beneficiary);
        require(_amount <= this.balance - alfatokenFee);
        _to.transfer(_amount);
    }
    
    function transferFee(address _to, uint _amount) public {
        require(msg.sender == alfatokenteam);
        require(_amount <= alfatokenFee);
        _to.transfer(_amount);
        alfatokenFee -= _amount;
    }

    function getBonus(uint amount) public constant returns (uint) {
        return amount * 35/100;
    }

    function getPrice() public constant returns (uint) {
        return 1250;
    }
}

pragma solidity ^0.4.11;

import "./MONETO.sol";

contract MONETOPreSale {
    MONETO public token;
    address public beneficiary;
    address public alfatokenteam;
    
    uint public amountRaised;
    
    uint public bonus;
    uint public price;    
    uint public minSaleAmount;
    
    uint public alfatokenFee;
    
     public startTime;
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

    function MONETOPreSale(
        MONETO _token,
        address _beneficiary,
        address _alfatokenteam
    ) {
        token = MONETO(_token);
        beneficiary = _beneficiary;
        alfatokenteam = _alfatokenteam;
        bonus = 35;
        price = 1250;
        minSaleAmount = 1000000000000000000;
        alfatokenFee = 7000000000000000000;
    }

    function () payable {
        uint amount = msg.value;
        uint tokenAmount = amount * price;
        if (tokenAmount < minSaleAmount) throw;
        amountRaised += amount;
        token.transfer(msg.sender, tokenAmount * (100 + bonus) / 100);
    }

    function TransferETH(address _to, uint _amount) {
        require(msg.sender == beneficiary);
        require(_amount <= this.balance - alfatokenFee);
        _to.transfer(_amount);
    }
    
    function TransferFee(address _to, uint _amount) {
        require(msg.sender == alfatokenteam);
        require(_amount <= alfatokenFee);
        _to.transfer(_amount);
        alfatokenFee -= _amount;
    }

    function TransferTokens(address _to, uint _amount) {
        require(msg.sender == beneficiary);
        token.transfer(_to, _amount);
    }

    function ChangeBonus(uint _bonus) {
        require(msg.sender == beneficiary);
        bonus = _bonus;
    }
    
    function ChangePrice(uint _price) {
        require(msg.sender == beneficiary);
        price = _price;
    }
    
    function ChangeMinSaleAmount(uint _minSaleAmount) {
        require(msg.sender == beneficiary);
        minSaleAmount = _minSaleAmount;
    }
}

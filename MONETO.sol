pragma solidity ^0.4.12;

import './StandardToken.sol';

contract MONETO is StandardToken {
  
  string constant public name = "MONETO";
  string constant public symbol = "MTO";
  uint8 constant public decimals = 18;

  function MONETO(address saleAddress) public {
    require(saleAddress != 0x0);

    totalSupply = 39500000000000000000000000;
    balances[saleAddress] = totalSupply;
    Transfer(0x0, saleAddress, totalSupply);

    assert(totalSupply == balances[saleAddress]);
  }

  function burn(uint num) public {
    require(num > 0);
    require(balances[msg.sender] >= num);
    require(totalSupply >= num);

    uint preBalance = balances[msg.sender];

    balances[msg.sender] -= num;
    totalSupply -= num;
    Transfer(msg.sender, 0x0, num);

    assert(balances[msg.sender] == preBalance - num);
  }
}
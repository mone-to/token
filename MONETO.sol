pragma solidity ^0.4.12;

import "./lib/BurnableToken.sol";
import "./lib/UpgradeableToken.sol";

contract MONETO is BurnableToken, UpgradeableToken {

  string public name;
  string public symbol;
  uint public decimals;

  function MONETO(address _owner)  UpgradeableToken(_owner) {
    name = "MONETO";
    symbol = "MTO";
    totalSupply = 39500000000000000000000000;
    decimals = 18;

    balances[_owner] = totalSupply;
  }
}
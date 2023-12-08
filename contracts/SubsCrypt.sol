// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SubsCryptControl.sol";

contract SubsCrypt is SubsCryptControl, Ownable {

    
    constructor(address _currencyToken) Ownable(msg.sender)  {
        CURRENCY_TOKEN = _currencyToken;
    }

}
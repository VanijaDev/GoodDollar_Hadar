// SPDX-License-Identifier: MIT

pragma solidity 0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract TokenX is ERC20("X", "XTKN") {
    constructor() public {
        _setupDecimals(2);
    }
}

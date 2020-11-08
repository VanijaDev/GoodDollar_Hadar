// SPDX-License-Identifier: MIT

pragma solidity 0.6.0;

import "./TokenX.sol";
import "./TokenY.sol";

contract X_Y_eschange {
    using SafeMath for uint256;

    TokenX tokenX;
    TokenY tokenY;

    uint256 constant X_to_Y_percentge = 35; //  1X = 0.35Y

    constructor(TokenX _tokenX, TokenY _tokenY) public {
        tokenX = _tokenX;
        tokenY = _tokenY;
    }

    function exchangeX_to_Y(uint256 _tokensX)
        external
        view
        returns (uint256 amountY)
    {
        uint8 correctDecimals = tokenY.decimals() - tokenX.decimals();
        amountY = _tokensX.mul(10**uint256(correctDecimals)).div(35).mul(100);
    }

    function exchangeY_to_X(uint256 _tokensY)
        external
        view
        returns (uint256 amountX)
    {
        uint8 correctDecimals = tokenY.decimals() - tokenX.decimals();
        amountX = _tokensY.mul(35).div(100).div(10**uint256(correctDecimals));
    }
}

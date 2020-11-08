//  "SPDX-License-Identifier: MIT"

pragma solidity 0.7.0;

contract ProoveMe {
    mapping(address => bytes32) public testForAddress;

    event Owner(address owner, address owned);

    function register() external {
        require(testForAddress[msg.sender] == 0x0, "Already registered");

        testForAddress[msg.sender] = keccak256(abi.encodePacked(msg.sender));
    }

    function prooveMe(
        bytes32 _testForAddress,
        bytes32 __testForAddressHash,
        bytes memory _proof
    ) external {
        require(testForAddress[msg.sender] == _testForAddress, "Wrong test");

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_proof);

        address ownerAddr = ecrecover(__testForAddressHash, v, r, s);
        require(ownerAddr == msg.sender, "Not owner");

        emit Owner(msg.sender, address(this));
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        private
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}

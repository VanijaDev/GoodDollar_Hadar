// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

contract ProoveMe {
    mapping (address => address) public provedOwnerForOwned;
    
    event Owner(address owner, address owned);
    
    
    
    function prooveMe(address _ownedAddr, bytes32 _messageHash, bytes memory _signature) external {
        require(provedOwnerForOwned[_ownedAddr] == address(0), "owner present");
        
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);

        address signerAddr = ecrecover(_messageHash, v, r, s);
        require(signerAddr == _ownedAddr, "Not owner");
        
        provedOwnerForOwned[_ownedAddr] = msg.sender;
        emit Owner(msg.sender, _ownedAddr);
    }
    
    function splitSignature(bytes memory sig) private pure returns (uint8 v, bytes32 r, bytes32 s) {
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

    function recoverSigner(bytes32 message, bytes memory sig) private pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}

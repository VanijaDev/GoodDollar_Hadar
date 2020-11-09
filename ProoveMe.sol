// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

contract ProveMe {
    mapping (address => address) public provedOwnerForOwned;
    mapping (address => bytes32) public messageForOwner; // should be signed by owned address, but send by owner as prove of owned address ownership
    mapping (address => bytes32) private messageForOwnerHashed;
    
    event Owner(address owner, address owned);
    
    /**
      *@dev Used for front run resistance. Each address should have individual messgae to be hashed by owned address.
    */
    function register() external {
        require(messageForOwner[msg.sender] == 0, "Already registered");
        
        bytes32 byteAddress = bytes32(uint256(msg.sender) << 96);
        messageForOwner[msg.sender] = byteAddress;
        
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        messageForOwnerHashed[msg.sender] = keccak256(abi.encodePacked(prefix, byteAddress));
    }
    
    function proveMe(address _ownedAddr, bytes memory _signature) external {
        require(provedOwnerForOwned[_ownedAddr] == address(0), "owner present");
        require(bytes32(uint256(msg.sender) << 96) == messageForOwner[msg.sender], "wrong sender");
        
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);

        address signerAddr = ecrecover(messageForOwnerHashed[msg.sender], v, r, s);
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

//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

interface IL2CrossDomainMessenger {
    function sendMessage(address _target, bytes calldata _message, uint32 _minGasLimit) external payable
}
interface IRiverProtocol {
    function grant() external;
}

contract Stream {

    address public constant STREAM = 0x42000000000000000000000000000000000000A0;
    constructor (address _owner)
    {
        owner = _owner;
    }
    function stream() external {
        require(msg.sender == owner || msg.sender == STREAM, "Not Authorized");
        if(lastCheck + 1 weeks > block.timestamp) return;
        bytes memory message = abi.encodeWithSelector(IRiverProcotol.grant.selector);
    }
}
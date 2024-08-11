//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;

interface IL2CrossDomainMessenger {
    function sendMessage(address _target, bytes calldata _message, uint32 _minGasLimit) external payable;
}
interface IRiverProtocol {
    function grant() external;
}

contract Stream {

    address public constant STREAM = 0x42000000000000000000000000000000000000A0;
    address public constant RIVER_PROTOCOL = address(0);
    address public constant L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000007;
    address public immutable owner;
    uint private lastCheck = 0;

    constructor (address _owner)
    {
        owner = _owner;
    }

    function stream() external {
        require(msg.sender == owner || msg.sender == STREAM, "Not Authorized");
        if(lastCheck + 1 weeks > block.timestamp) return;
        bytes memory message = abi.encodeWithSelector(
            IRiverProtocol.grant.selector
        );
        IL2CrossDomainMessenger(L2_CROSS_DOMAIN_MESSENGER).sendMessage(
            RIVER_PROTOCOL,
            message,
            300000
        );
        lastCheck = block.timestamp;
    }
}
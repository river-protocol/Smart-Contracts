//SPDX-License-Identifier:MIT
pragma solidity 0.8.23;
/* EAS attestations to be included in future.
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SchemaResolver } from "@eas/contracts/resolver/SchemaResolver.sol";
import { IEAS, Attestation } from "@eas/contracts/IEAS.sol";
//resolver for initiaing funding upon attestation
contract PayingResolver is SchemaResolver {
    using Address for address payable;

    error InvalidValue();

    uint256 private immutable _incentive;

    constructor(IEAS eas, uint256 incentive) SchemaResolver(eas) {
        _incentive = incentive;
    }

    function isPayable() public pure override returns (bool) {
        return true;
    }

    function onAttest(Attestation calldata attestation, uint256 value) internal override returns (bool) {
        if (value > 0) {
            return false;
        }

        payable(attestation.attester).transfer(_incentive);

        return true;
    }

    function onRevoke(Attestation calldata attestation, uint256 value) internal override returns (bool) {
        if (value < _incentive) {
            return false;
        }

        if (value > _incentive) {
            payable(address(attestation.attester)).sendValue(value - _incentive);
        }

        return true;
    }
} */
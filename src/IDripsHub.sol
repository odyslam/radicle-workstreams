// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

interface IDripsHub {
    struct PermitArgs {
        uint256 nonce;
        uint256 expiry;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct DripsReceiver {
        address receiver;
        uint128 amtPerSec;
    }

    function setDripsAndPermit(
        uint256 account,
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers,
        int128 balanceDelta,
        DripsReceiver[] memory newReceivers,
        PermitArgs calldata permitArgs
    ) external returns (uint128 newBalance, int128 realBalanceDelta);

    function setDrips(
        uint256 account,
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers,
        int128 balanceDelta,
        DripsReceiver[] memory newReceivers
    ) external returns (uint128 newBalance, int128 realBalanceDelta);
}

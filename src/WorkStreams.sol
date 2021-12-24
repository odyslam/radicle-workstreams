// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import {IOrgV1} from "./IOrgV1.sol";
import {RolesAuthority} from "solmate/auth/authorities/RolesAuthority.sol";
import {SSTORE2} from "solmate/utils/SSTORE2.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SafeCastLib} from "solmate/utils/SafeCastLib.sol";
import {IDripsHub} from "./IDAIDripsHub.sol";

/*///////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/
error NoAuthorisation(
    string functionality,
    string allowed,
    uint8 workStreamType
);

contract Workstreams {
    /*///////////////////////////////////////////////////////////////
                             LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using FixedPointMathLib for uint256;
    using SafeCastLib for uint256;

    /*///////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/
    event WorkstreamCreated(address indexed org, address workStreamId);

    uint256 public constant BASE_UNIT = 10e18;

    mapping(address => address) public workstreamIdToOrgAddress;

    uint256 internal accountCounter;
    IDripsHub internal daiDripsHub;

    /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address dripsHubAddress) {
        daiDripsHub = IDripsHub(dripsHubAddress);
    }

    function createDaiWorkStream(
        address orgAddress,
        string calldata projectId,
        string calldata anchor,
        IDripsHub.DripsReceiver[] calldata workstreamMembers,
        int128 initialAmount,
        IDripsHub.PermitArgs calldata permitArgs
    ) external returns (address) {
        accountCounter++;
        address workstreamId = fundWorkstreamDai(
            address(0),
            projectId,
            anchor,
            orgAddress,
            accountCounter,
            workstreamMembers,
            initialAmount,
            permitArgs
        );
        workstreamIdToOrgAddress[workstreamId] = orgAddress;
        emit WorkstreamCreated(orgAddress, workstreamId);
        return workstreamId;
    }

    function storeWorkstream(
        string memory projectId,
        string memory anchor,
        uint8 workstreamType,
        address org,
        uint256 account,
        uint64 lastTimestamp,
        int128 newBalance,
        IDripsHub.DripsReceiver[] calldata newReceivers
    ) internal returns (address) {
        return
            SSTORE2.write(
                abi.encode(
                    projectId,
                    anchor,
                    workstreamType,
                    org,
                    account,
                    lastTimestamp,
                    newBalance,
                    newReceivers
                )
            );
    }

    function loadWorkstream(address key)
        internal
        view
        returns (
            string memory,
            string memory,
            uint8,
            address,
            uint256,
            uint64,
            uint128,
            IDripsHub.DripsReceiver[] memory
        )
    {
        return
            abi.decode(
                SSTORE2.read(key),
                (
                    string,
                    string,
                    uint8,
                    address,
                    uint256,
                    uint64,
                    uint128,
                    IDripsHub.DripsReceiver[]
                )
            );
    }

    function fundWorkstreamDai(
        address workstreamId,
        string memory projectId,
        string memory anchor,
        address org,
        uint256 account,
        IDripsHub.DripsReceiver[] calldata newReceivers,
        int128 amount,
        IDripsHub.PermitArgs calldata permitArgs
    ) public returns (address) {
        if (workstreamId == address(0)) {
            IDripsHub.DripsReceiver[] memory oldReceivers;
            daiDripsHub.setDripsAndPermit(
                account,
                0,
                0,
                oldReceivers,
                amount,
                newReceivers,
                permitArgs
            );
        } else {
            fundExisting(
                workstreamId,
                account,
                amount,
                newReceivers,
                permitArgs
            );
        }
        return
            storeWorkstream(
                projectId,
                anchor,
                1,
                org,
                account,
                uint64(block.timestamp),
                amount,
                newReceivers
            );
    }

    function fundExisting(
        address workstreamId,
        uint256 account,
        int128 amount,
        IDripsHub.DripsReceiver[] calldata newReceivers,
        IDripsHub.PermitArgs calldata permitArgs
    ) internal {
        IDripsHub.DripsReceiver[] memory receivers;
        uint64 lastTimestamp;
        uint128 balance;
        address org;
        (
            ,
            ,
            ,
            org,
            account,
            lastTimestamp,
            balance,
            receivers
        ) = loadWorkstream(workstreamId);
        daiDripsHub.setDripsAndPermit(
            account,
            lastTimestamp,
            balance,
            receivers,
            amount,
            newReceivers,
            permitArgs
        );
    }
}

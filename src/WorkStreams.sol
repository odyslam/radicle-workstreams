// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import {IOrgV1} from "./IOrgV1.sol";
import {RolesAuthority} from "solmate/auth/authorities/RolesAuthority.sol";
import {SSTORE2} from "solmate/utils/SSTORE2.sol";
import {FixedPointMathLib} from  "solmate/utils/FixedPointMathLib.sol";
import {SafeCastLib} from "solmate/utils/SafeCastLib.sol";
import {IDAIDripsHub} from "./IDAIDripsHub.sol";

// -------------- ERRORS ----------------------

error NoAuthorisation(string functionality, string allowed, uint8 workStreamType);


// -------------- EVENTS ----------------------


contract Workstreams {
    using FixedPointMathLib for uint256;
    using SafeCastLib for uint256;

    struct DripsReceiver {
        address receiver;
        int128 amtPerSec;
    }
    event WorkstreamCreated(address indexed org, address workStreamId);

    uint256 public constant BASE_UNIT = 10e18;

    mapping(address => address) workstreamIdToOrgAddress;

    uint256 accountCounter;
    IDAIDripsHub daiDripsHub;

    constructor(address dripsHubAddress){
        daiDripsHub = IDAIDripsHub(dripsHubAddress);
    }
    function createDaiWorkStream(address orgAddress, bytes32 anchorId, DripsReceiver[] calldata workstreamMembers, int128 initialAmount, IDAIDripsHub.PermitArgs calldata permitArgs)
        external
        returns(int128 id)
    {
        accountCounter++;
        IOrgV1 org = IOrgV1(orgAddress);
        (uint32 tag, bytes memory multihash) = org.anchors(anchorId);
        IOrgV1.Anchor memory anchor = IOrgV1.Anchor(tag, multihash);
        address workstreamId = fundWorkstreamDai(address(0), anchor, orgAddress, accountCounter, workstreamMembers, initialAmount, permitArgs);
        workstreamIdToOrgAddress[workstreamId] = orgAddress;
        emit WorkstreamCreated(orgAddress, workstreamId);
    }


    function storeWorkstream(IOrgV1.Anchor memory anchor,
                             uint8 workstreamType,
                             address org,
                             uint256 account,
                             uint64 lastTimestamp,
                             int128 newBalance,
                             DripsReceiver[] calldata newReceivers
                            )
        internal
        returns(address)
    {
        return SSTORE2.write(abi.encode(anchor, workstreamType, org, account, lastTimestamp, newBalance, newReceivers));
    }

    function loadWorkstream(address key)
        internal
        returns(IOrgV1.Anchor memory,
                uint8,
                address,
                uint256,
                uint64,
                int128,
                DripsReceiver[] memory
               )
    {
        return abi.decode(SSTORE2.read(key),(IOrgV1.Anchor, uint8, address, uint256, uint64,
                                             int128, DripsReceiver[] ));
    }

    function fundWorkstreamDai(address workstreamId, IOrgV1.Anchor memory anchor, address org, uint256 account, DripsReceiver[] calldata newReceivers,
                               int128 amount, IDAIDripsHub.PermitArgs calldata permitArgs)
       public
       returns(address)
    {
        DripsReceiver[] memory oldReceivers;
        if(workstreamId == address(0)){
            daiDripsHub.setDripsAndPermit(account, 0, 0, oldReceivers, amount, newReceivers, permitArgs);
        } else {
            uint8 dripType;
            DripsReceiver[] memory receivers;
            uint64 lastTimestamp;
            int128 balance;
            (anchor, dripType, org, account, lastTimestamp,
             balance, receivers) = loadWorkstream(workstreamId);
            daiDripsHub.setDripsAndPermit(account, lastTimestamp, balance, receivers, amount, newReceivers, permitArgs);
        }
        return storeWorkstream(anchor, 1, org, account, block.timestamp, amount, newReceivers);
    }
}

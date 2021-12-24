// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import {Hevm} from "./Hevm.sol";
import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {IOrgV1} from "../../IOrgV1.sol";

contract user is DSTestPlus {}

contract WorkStreamTest is DSTestPlus {
    IOrgV1 exampleOrg;

    function setUp() public {
        address exampleOrgAddress = 0xe22450214b02C2416481aC2d3Be51536f7bb1fFf;
        exampleOrg = IOrgV1(exampleOrgAddress);
    }
}

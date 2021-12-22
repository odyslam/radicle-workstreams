// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;


interface IOrgV1 {

    address public owner;

    mapping (bytes32 => Anchor) public anchors;

    struct Anchor
    {
        uint32 tag;
        bytes multihash;
    }

}

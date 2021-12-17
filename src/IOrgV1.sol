// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;


interface IOrgV1 {

    address public owner;

    mapping (bytes32 => Anchor) public anchors;

    struct Anchor
    {
    // A tag that can be used to discriminate between anchor types.
    uint32 tag;
    // The hash being anchored in multihash format.
    bytes multihash;
    }

}

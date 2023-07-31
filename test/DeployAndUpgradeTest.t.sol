// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployBox} from "../script/DepolyBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployBox;
    UpgradeBox public upgrader;
    address public OWNER = makeAddr("owner");

    address public proxy;

    function setUp() public {
        deployBox = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployBox.run(); // points to BoxV1
    }

    function testProxyStartsAsBoxV1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(7);
    }
    // function testDeploymentIsV1() public {
    //     address proxyAddress = deployBox.deployBox();
    //     uint256 expectedValue = 7;
    //     vm.expectRevert();
    //     BoxV2(proxyAddress).setNumber(expectedValue);
    // }

    function testBoxWorks() public {
        address proxyAddress = deployBox.deployBox();
        uint256 expectedValue = 1;
        assertEq(expectedValue, BoxV1(proxyAddress).version());
    }

    function testUpgrades() public {
        BoxV2 box2 = new BoxV2();

        upgrader.upgradeBox(proxy, address(box2));

        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxy).version());

        BoxV2(proxy).setNumber(7);
        assertEq(7, BoxV2(proxy).getNumber());
    }

    // function testUpgradeWorks() public {
    //     address proxyAddress = deployBox.deployBox();

    //     BoxV2 box2 = new BoxV2();

    //     vm.prank(BoxV1(proxyAddress).owner());
    //     BoxV1(proxyAddress).transferOwnership(msg.sender);

    //     upgrader.upgradeBox(proxyAddress, address(box2));

    //     uint256 expectedValue = 2;
    //     assertEq(expectedValue, BoxV2(proxy).version());

    //     BoxV2(proxy).setNumber(expectedValue);
    //     assertEq(expectedValue, BoxV2(proxy).getNumber());
    // }
}

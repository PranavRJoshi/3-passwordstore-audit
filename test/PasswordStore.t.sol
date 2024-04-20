// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract PasswordStoreTest is Test {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;

    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
    }

    function test_owner_can_set_password() public {
        vm.startPrank(owner);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }

    function test_non_owner_reading_password_reverts() public {
        vm.startPrank(address(1));

        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        passwordStore.getPassword();
    }

    // @audit-test Function to test whether anyone can set the password or not
    // @notice Here, we assume that someone having an address of random_address can interact with an existing contract, 
    // call the setPassword function and change the password even though random_address is not the owner
    function test_anyone_can_set_password(address random_address) public {
        vm.assume(random_address != owner); // assuming that the random_address is any address apart from the owner's address
        vm.prank(random_address); // interacting with the contract using random_address
        string memory expected_password = "myNewPassword";
        passwordStore.setPassword(expected_password); // calling the setPassword method by the random_address

        vm.prank(owner); // interacting the contract with the owner's address
        string memory actual_password = passwordStore.getPassword(); // calling the getPassword method using the owner's address
        assertEq(actual_password, expected_password); // assert the two variables to be equal, else throw an error
    }
}

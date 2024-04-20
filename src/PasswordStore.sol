// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; // q is this compiler version the best suited

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
contract PasswordStore {
    /* ////////////////////////////////////////////////////////
                            Error Functions
      //////////////////////////////////////////////////////// */
    error PasswordStore__NotOwner();

    /* ////////////////////////////////////////////////////////
                            State Variables
      //////////////////////////////////////////////////////// */
    address private s_owner;
    // @audit the variable stores the raw password given by the user, its better to use a hash function to encrypt the password
    string private s_password;
 
    /* ////////////////////////////////////////////////////////
                                Events
      //////////////////////////////////////////////////////// */    
    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */
    // q can some non-owner call the function and set the password?
    // q should some non-owner call the function and set the password?
    // @audit any user can set the password
    // missing access control - there is no prevention to limit the function to only owner
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     * @param newPassword The new password to set.
     */
    // @audit the function takes no parameter (newPassword) as described in the doc
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}

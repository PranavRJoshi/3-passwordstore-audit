### [H-1] Storing The Password On-Chain Makes It Visible To Anyone, And No Longer Private.

**Description:**

All data stored on-chain is visible to anyone, and can be read directly from the blockchain. The `PasswordStore::s_password` variable is intended to be a private variable and only accessed through the `PasswordStore::getPassword` function, which is intended to be only called by the owner of the contract.

We show one such method of reading any data off chain below.

**Impact:**

Anyone can read the private password, which breaks the actual functionality of the protocol.

**Proof of Concept:** (Proof of Code)

The below test case shows how anyone can read the password directly from the blockchain.

1. Create a locally running chain:
```bash
    make anvil
```
2. Deploy the contract to the chain:
```bash
    make deploy
```
3. Run the storage tool:
   1. We use 1 because that's the storage slot for of `s_password` in the contract.
    ```bash
        cast storage <ADDRESS-HERE> 1 --rpc-url http://127.0.0.1:8545
    ```
   2. You'll get an output that looks like this:

        `0x6d7950617373776f726400000000000000000000000000000000000000000014`

   3. You can parse the hex value to string using:
    ```bash
        cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
    ```
   4. This returns the value:
        
        `myPassword`

**Recommended Mitigation:** 

With the nature of the protocol, the overall architecture it should be reconsidered. One could encrypt the password off-chain and then store the encrypted password on-chain. However, this would require the user to remember another password off-chain to decrypt the on-chain encrypted password. Also, you'd also likely want to remove the view function as you wouldn't want the user to accidently send a transaction with the password that decrypts your password.

Password --> Encryption Layer --> Encrypted Password --> Fetch Password --> Decrypt Password --> Original Password

|Stage|Chain|
|--------|--------|
|Password|Off-Chain|
|Encryption Layer|Off-Chain|
|Encrypted Password|On-Chain|
|Fetch Password|On-Chain|
|Decrypt Password|Off-Chain|
|Original Password|Off-Chain|


### [H-2] `PasswordStore::setPassword` has no access control, meaning a non-owner could change the password 

**Description:** 

`PasswordStore:setPassword` function has the external visibility, however the natspec of the function (@notice) and overall purpose of the smart contract is that `This function allows only the owner to set a new password`

```javascript
    function setPassword(string memory newPassword) external {
->        // @audit There are no access controls 
        s_password = newPassword;
        emit SetNetPassword();
    }
```

**Impact:** 

Anyone can set or change the password of the contract, severly breaking the contract's intended functionality.

**Proof of Concept:**

Add the following code to the `PasswordStore.t.sol`

<details>
<summary>Code</summary>

```javascript
    function test_anyone_can_set_password(address random_address) public {
        vm.assume(random_address != owner); 
        vm.prank(random_address); 
        string memory expected_password = "myNewPassword";
        passwordStore.setPassword(expected_password); 

        vm.prank(owner); 
        string memory actual_password = passwordStore.getPassword(); 
        assertEq(actual_password, expected_password); 
    }
```

</details>

**Recommended Mitigation:** 

Add an access control condition to the `setPassword` function.

```javascript
    if (msg.sender != s_owner) {
        revert PasswordStore__NotOwner();
    }
```


### [I-1] The `PasswordStore::getPassword` natspec indicates a parameter that doesn't exist, causing the natspec to be incorrect

**Description:** 

```javascript
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
```

The `PasswordStore::getPassword` function signature is `getPassword()` while the natspec says it should be `getPassword(string)`.

**Impact:** 

The natspec is incorrect.

**Recommended Mitigation:** 

Remove the incorrect natspec line.

```diff
-   * @param newPassword The new password to set.
```
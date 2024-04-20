### [S-#] Storing The Password On-Chain Makes It Visible To Anyone, And No Longer Private.

**Description:**

All data stored on-chain is visible to anyone, and can be read directly from the blockchain. The `PasswordStore::s_password` variable is intended to be a private variable and only accessed through the `PasswordStore::getPassword` function, which is intended to be only called by the owner of the contract.

We show one such method of reading any data off chain below.

**Impact:**

Anyone can read the private password, which breaks the actual functionality of the protocol.

**Proof of Concept:** (Proof of Code)

The below test case shows how anyone can read the password directly from the blockchain.

1. Create a locally running chain:
    ```
    make anvil
    ```
2. Deploy the contract to the chain:
    ```
    make deploy
    ```
3. Run the storage tool:
   1. We use 1 because that's the storage slot for of `s_password` in the contract.
        ```
        cast storage <ADDRESS-HERE> 1 --rpc-url http://127.0.0.1:8545
        ```
   2. You'll get an output that looks like this:

        `0x6d7950617373776f726400000000000000000000000000000000000000000014`

   3. You can parse the hex value to string using:
        ```
        cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
        ```
   4. This returns the value:
        
        `myPassword`

**Recommended Mitigation:**
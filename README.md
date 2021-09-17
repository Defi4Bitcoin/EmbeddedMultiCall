# EmbeddedMultiCall
EmbeddedMultiCall is a tiny piece of code that enables performing multiple calls to contracts in a single call. Regarding functionality, it is similar to the Makerdao's Multicall contract (deployed both in [Ethereum](https://github.com/makerdao/multicall) and in [RSK](https://github.com/makerdao/multicall)). However EmbeddedMultiCall works right from web3 eth_call() without the need to deploy the contract. To be able to execute multiple calls and return the data collected, EmbeddedMultiCall uses a special trick: it creates a new contract each time it is called, and the contract code installed (which is in returned by eth_call() corresponds to the list or return values, instead of code).
EmbeddedMultiCall also provides some minimal scripting features present in Hughes's [Multicall batching system](https://dl.acm.org/doi/abs/10.1145/3457337.3457839)  (which should not be confused with Makerdao's).

To be compact, EmbeddedMultiCall is written directly in Yul, an experimental assembly-like language that is used internally by Solidity. While the code is readable, it is not intended to be super clear, but only to be short. Also, the code is not intended to be deployed in any blockchain, but only to be used in offchain web3 calls. To keep the code short, it doesn't undestand the Soldity ABI argument format, but uses the simplest format that can be interpreted in Yul.

EmbeddedMultiCall accept commands of two kinds: CALL and BALANCE. The CALL command goal is obvious, it calls a contract (without passing value). The BALANCE command can be used to query multiple balances of contracts or EOA in a single eth_call().

EmbeddedMultiCall has one optional features: if indicated, it can return the gas consumed by each call.

# Input Format

* uint32: input size (total input size, including this field)
* uint32: gaslimitpercall (amount of gas that should be passed to each call)
* uint8: returnGasUsed (1 = yes / 0 = no)

For each command requested:

* uint8: command (0==CALL, 1==BALANCE)
* uint160: contract address (for both commands)
* uint32: calldata size (only for CALL)
* byte[]: calldata (in Solidity ABI format, only for CALLs)


# Output Format

* uint32: block number of the block in which it was executed 
* uint256: block hash of the block in which it was executed
* uint32: Number of commands processed
* .... variable data for all commands...
* uint32: total gas consumed

For each command requested:

If the command was CALL:
* uint32: gas consumed by CALL (only present if returnGasUsed==1)
* uint8: return value of CALL (1==sucess, 0==failure)
* uint32: size of returned data for this CALL
* ... returned data ....

If the command was BALANCE:
* uint256: balance of account

# Testing

While the code in this repository does yet have an interface with a language-specific web3 library, I included curl examples to test it:

* compile.sh: compiles the code in Yul and extracts the code from the Solidity output (I don't know if Solidity is able to extract the binary part by itself)

* m2c.sh: packsthe code with some sample arguments and uses curl to retrieve the results from a public web3 server.
 
Note that these test scripts are not inteded to be used in production environments, and may contain flaws or be vulnerable. Also the public web3 service used may cease to operate at any time.

# Contribuitions

If you think you can improve EmbeddedMultiCall, plase contribute with issues or PRs, and I'll do my best to merge them. Standard interfaces with web3 libraries such as web3.js and nethermind are welcomed.

# Disclaimer

This software is provided "as is" without warranty of any kind, either express or implied. Use at your own risk.


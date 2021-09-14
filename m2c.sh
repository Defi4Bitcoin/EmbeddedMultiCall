code=$(<code.txt)
##echo "code is: $code"
data='{
	"jsonrpc":"2.0",
	"method":"eth_call",
	"params":[{
		"from": "0x0102030405060708090A0102030405060708090A",
		"gas": "0x100000",
		"gasPrice": "",
		"value": "",
		"data": "0x'

end='"
	}, "latest"],
	"id":1
}'

## Input Format:
## uint32: input size
## uint32: gaslimitpercall
## uint8: returnGasUsed
##   uint8: command (0==CALL, 1==BALANCE)
##   uint160: contract address (for both commands)
##   uint32: calldata size (only for CALL)
##   byte[]: calldata (only for CALL)
##
## Output:
## uint256: block number
## uint256: block hash
##   .... returned data ....
## uint32: total gas used

## This is the ETH2.0 staking contract. It should have 7,659,810 ether
calls_eth2_balance="\
0000001e\
0000ffff\
01\
01\
00000000219ab540356cbb839cbe05303d7705fa"

## Call identity contract and return the same 10 bytes
call_identity="\
00000010\
0000ffff\
01\
\
00\
0000000000000000000000000000000000000004\
0000000A\
0102030405060708090A"

## 0: preamble (size 9)
## 1: call identity, return 10 bytes (size 35 bytes)
## 2: return totalSupply of tether contract (size 29)
## 3: return balance of eth2 contact (aprox 7M ether = 0x6560721d4420c6fc55045) (size 21)
## 4: return balance of eth of contact 0x00 (aprox 11,269 ether = 0x262ea4d53e15cf4a89f) (size 21)
## total size: 9+35+29+21+21 = 115 (0x73)
calls="\
00000073\
0000ffff\
01\
\
00\
0000000000000000000000000000000000000004\
0000000A\
0102030405060708090A\
\
00\
dac17f958d2ee523a2206206994597c13d831ec7\
00000004\
18160DDD\
\
01\
00000000219ab540356cbb839cbe05303d7705fa\
\
01\
0000000000000000000000000000000000000000"


echo "arguments:$calls"

all=$data$code$calls$end
echo "all:$all"

curl --location --request POST 'https://main-light.eth.linkpool.io/' \
--header 'Content-Type: application/json' \
--data-raw "$all"



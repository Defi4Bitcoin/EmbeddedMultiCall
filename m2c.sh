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
## Format:
## uint32: input size
## uint32: gaslimitpercall
##   uint160: contract address
##   uint32: calldata size
##   byte[]: calldata

calls="\
00000047\
0000ffff\
01\
0000000000000000000000000000000000000004\
0000000A\
0102030405060708090A\
dac17f958d2ee523a2206206994597c13d831ec7\
00000004\
18160DDD"
all=$data$code$calls$end
echo "all:$all"

curl --location --request POST 'https://main-light.eth.linkpool.io/' \
--header 'Content-Type: application/json' \
--data-raw "$all"



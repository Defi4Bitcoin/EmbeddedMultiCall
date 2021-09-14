##sed -n '/Binary representation/ {n;p}' out.txt
awk '/Binary representation:/{getline;print}' out.txt >code.txt
value=$(<code.txt)
echo "code is: $value"
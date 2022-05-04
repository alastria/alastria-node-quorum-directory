#!/bin/bash

# Check TYPE
if [[ ! $TYPE =~ ^(regular|bootnode|validator)$ ]]; then
	echo "ERROR: invalid input 'type'"
	echo "ERROR: node type $TYPE not recognized"
	exit 1
fi

# Check NAME
case $TYPE in
	"bootnode")
		if [[ ! $NAME =~ ^BOT_[a-zA-Z0-9_]+_T_[0-9][0-9]?_[0-9][0-9]?_[0-9][0-9]?$ ]]; then
			echo "ERROR: invalid input 'name'"
			echo "ERROR: node name $NAME of type $TYPE doesn't match expression ^BOT_[a-zA-Z0-9]+_T_[0-9][0-9]?_[0-9][0-9]?_[0-9][0-9]?$"
			exit 1
		fi
		if grep -q $NAME ./DIRECTORY_BOOTNODES.md; then
			echo "ERROR: invalid input 'name'"
			echo "ERROR: node name $NAME already present in DIRECTORY_BOOTNODES.md"
			exit 1
		fi
	;;
	"validator")
		if [[ ! $NAME =~ ^VAL_[a-zA-Z0-9_]+_T_[0-9][0-9]?_[0-9][0-9]?_[0-9][0-9]?$ ]]; then
			echo "ERROR: invalid input 'name'"
			echo "ERROR: node name $NAME of type $TYPE doesn't match expression ^VAL_[a-zA-Z0-9]+_T_[0-9][0-9]?_[0-9][0-9]?_[0-9][0-9]?$"
			exit 1
		fi
		if grep -q $NAME ./DIRECTORY_VALIDATOR.md; then
			echo "ERROR: invalid input 'name'"
			echo "ERROR: node name $NAME already present in DIRECTORY_VALIDATOR.md"
			exit 1
		fi
	;;
	"regular")
		if [[ ! $NAME =~ ^REG_[a-zA-Z0-9_]+_T_[0-9][0-9]?_[0-9][0-9]?_[0-9][0-9]?$ ]]; then
			echo "ERROR: invalid input 'name'"
			echo "ERROR: node name $NAME of type $TYPE doesn't match expression ^REG_[a-zA-Z0-9]+_T_[0-9][0-9]?_[0-9][0-9]?_[0-9][0-9]?$"
			exit 1
		fi
		if grep -q $NAME ./DIRECTORY_REGULAR.md; then
			echo "ERROR: invalid input 'name'"
			echo "ERROR: node name $NAME already present in DIRECTORY_REGULAR.md"
			exit 1
		fi
	;;
esac

# Check ENODE
if [[ ! $ENODE =~ ^enode:\/\/[0-9a-f]{128}@((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9]):21000\?discport=0$ ]]; then
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: enode address $ENODE is incorrect. Possible causes: incorrect number of characters, invalid IP address format, specified port is different to 21000, param 'discport' has value different to 0, or any other kind of malformed address."
	exit 1
fi

enode_hex="$(echo $ENODE | sed -n "s/^.*\/\/\(\S*\)@.*$/\1/p")"
if grep -q $enode_hex ./DIRECTORY_REGULAR.md; then
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: enode $enode_hex already present in DIRECTORY_REGULAR.md"
	exit 1
fi
if grep -q $enode_hex ./DIRECTORY_BOOTNODES.md; then
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: enode $enode_hex already present in DIRECTORY_BOOTNODES.md"
	exit 1
fi
if grep -q $enode_hex ./DIRECTORY_VALIDATOR.md; then
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: enode $enode_hex already present in DIRECTORY_VALIDATOR.md"
	exit 1
fi

ip="$(echo $ENODE | sed -n "s/^.*@\(\S*\):21000.*$/\1/p")"
if grep -q $ip ./DIRECTORY_REGULAR.md; then
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: ip $ip already present in DIRECTORY_REGULAR.md"
	exit 1
fi
if grep -q $ip ./DIRECTORY_BOOTNODES.md; then
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: ip $ip already present in DIRECTORY_BOOTNODES.md"
	exit 1
fi
if grep -q $ip ./DIRECTORY_VALIDATOR.md; then
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: ip $ip already present in DIRECTORY_VALIDATOR.md"
	exit 1
fi

ip_response=$(curl -s -X POST -F "host=$ip" https://ping.eu/action.php?atype=12)
if grep -q "</STRONG> located in <STRONG>" <<< "$ip_response"; then
	countries='^(Austria|Belgium|Bulgaria|Croatia|Cyprus|Czech Republic|Denmark|Estonia|Finland|France|Germany|Greece|Hungary|Ireland|Italy|Latvia|Lithuania|Luxembourg|Malta|Netherlands|Poland|Portugal|Romania|Slovakia|Slovenia|Spain|Sweden)$'
	country=$(echo "$ip_response" | tr -d '\n\r' | sed -n "s/^.*located in <STRONG>\(.*\)<\/STRONG>.*$/\1/p")
	if [[ ! $country =~ $countries ]]; then
		echo "ERROR: invalid input 'enode'"
		echo "ERROR: ip $ip is not from an EU country"
		exit 1
	fi
else
	echo "ERROR: invalid input 'enode'"
	echo "ERROR: ip $ip is not a valid public ip address"
	exit 1
fi

# Check ADDRESS
if [[ $TYPE =~ ^validator$ ]]; then
	if [[ ! $ADDRESS =~ ^0x[0-9a-f]{40}$ ]]; then
		echo "ERROR: invalid input 'address'"
		echo "ERROR: address $ADDRESS is not valid"
		exit 1
	fi
	
	simplified_address="$(echo $ADDRESS | sed -n "s/^0x\(\S*\)$/\1/p")"
	if grep -q $simplified_address ./DIRECTORY_VALIDATOR.md; then
		echo "ERROR: invalid input 'address'"
		echo "ERROR: address $simplified_address already present in DIRECTORY_VALIDATOR.md"
		exit 1
	fi
fi

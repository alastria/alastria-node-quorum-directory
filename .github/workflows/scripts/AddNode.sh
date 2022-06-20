#!/bin/bash

case $TYPE in
	"bootnode")
		echo "| $NAME | $HOSTING | - | $ENODE |" >> ./DIRECTORY_BOOTNODES.md
		echo "$NAME $ENODE" >> ./directory.bot
		echo "\"$ENODE\"," >> ./data/boot-nodes.json
	;;
	"validator")
		echo "| $NAME | $HOSTING | $ENODE | $ADDRESS | True |" >> ./DIRECTORY_VALIDATOR.md
		echo "$NAME $ENODE" >> ./directory.val
		echo "\"$ENODE\"," >> ./data/validator-nodes.json
	;;
	"regular")
		echo "| $NAME | $HOSTING | - | $ENODE |" >> ./DIRECTORY_REGULAR.md
		echo "$NAME $ENODE" >> ./directory.reg
		echo "\"$ENODE\"," >> ./data/regular-nodes.json
	;;
esac

#!/bin/bash

if [ $1 == "sentinel" -o $1 == "Sentinel" -o $1 == "SENTINEL" ]
	then
		echo "Sentinel building."
		exit 0
fi

if [ $1 == "bda" -o $1 == "BDA" ]
	then
		echo "BDA building."
		exit 0
fi

if [ -z $1 -o $1 != "bda" -o $1 != "BDA" -o $1 != "Sentinel" -o $1 != "sentinel" -o $1 != "SENTINEL" ]
	then
		echo "Please pass an argument. Sentinel or BDA."
		exit 0
fi

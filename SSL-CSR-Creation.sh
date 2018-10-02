# !/bin/bash
read -p "Enter [1] to create an RSA private key, and [2] to create CSR file using an existing key:  " menu
if [ $menu = 1 ]
    then
        read -p "Please input the name for the SSL key:  " keyname 
        read -p "Please input the bit size (2048 or 4096):  " bitsize
        sleep 1
        openssl genrsa -out $keyname.key $bitsize
        echo "Done."
        read -p "Do you whish to immediatley create a CSR file using the created key? ([Y]es / [N]o):  " selection
            if [ $selection = Y ]
            then
            read -p "Please input the name you'd like the CSR file to have:" csrname
            openssl req -new -key $keyname.key -sha256 -out $csrname.csr
            echo "Done."
            fi
    elif [ $menu = 2 ]
    then
        read -p "Please input the path to the SSL Key to create the CSR file:" sslkey
        sleep 1
        read -p "Please input the name you'd like the CSR file to have:" csrname
        openssl req -new -key $sslkey.key -sha256 -out '$srname'.csr
        echo "Done."
    else
    echo "Aborting."
fi
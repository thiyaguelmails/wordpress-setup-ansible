#!/bin/bash

usage() {
  CMD=`basename $0`
  echo "Usage: To enable passwordless authentication on a server."
  echo "$CMD -u user_name -i ip_of_server -k [path_of_keypair]"
  echo "               user_name        :     Mandatory - Username in server to enable passwordless authentication"
  echo "               ip_of_server     :     Mandatory - IP of server to enable passwordless authentication"
  echo "               path_of_keypair  :     Optional - complete of ssh keypair to login with server"
  exit 1
}


while getopts "u:i:k:h" opt; do
  case $opt in
    # variable options
    u)  USER=$OPTARG ;;
    i)  IP=$OPTARG ;;
    k)  KEY=$OPTARG ;;
    h)  usage ;;
  esac
done

[ -z "${USER}" ] && echo "Username cannot be empty" && exit
[ -z "${IP}" ] && echo "IP of server cannot be empty" && exit

if [[ -z "${KEY}" ]]; then
  cat ~/.ssh/id_rsa.pub | ssh ${USER}@${IP} "cat >> .ssh/authorized_keys";
else
  cat ~/.ssh/id_rsa.pub | ssh -i ${KEY} ${USER}@${IP} "cat >> .ssh/authorized_keys";
fi

exit;



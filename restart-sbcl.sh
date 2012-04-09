logfile=$(echo "ski73/log/$(date +'%y%m').log")
date=$(date +"%y-%m-%d %H-%M-%S")

echo "$date kill sbcl" >> $logfile

pkill sbcl

echo "$date start ski73 sbcl" >> $logfile

sbcl/run-sbcl.sh --core ~/sbcl-core



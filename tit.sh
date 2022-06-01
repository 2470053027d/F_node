#! /bin/bash
mkdir lock
f_f=/root/lock
if [ ! -f "f_f/ip" ];then
        ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}'  >$f_f/ip
fi
if [ ! -f "$f_f/update" ];then
        apt update
        apt upgrde
        apt install -y mongodb
        apt install -y openjdk-8-jdk-headless
        >$f_f/update
fi

this_ip=$(cat $f_f/ip)
kaitou="java -jar shuttle.jar --wallet-url http://$this_ip:10004 --url http://216.250.254.183:8889"

PID_wallet=`ps aux|grep "wallet-web-pro-2.0.1.jar" |grep -v grep |wc -l`
if [ $PID_wallet -eq 0 ];then
    cd  /root/walletdir
    nohup  java -jar wallet-web-pro-2.0.1.jar &
    exit 1;
fi

qb(){

echo "--------------导入钱包---------------"
read -p "请输入地址:" address
echo $address >$f_f/Address
read -p "请输入私钥:" privateKey
echo $privateKey >$f_f/Privatekey
read -p "请输入公钥" publicKey
echo $publicKey >$f_f/Publickey

ADO=$(cat $f_f/Address)
ADC=$(cat $f_f/Privatekey)
ADE=$(cat $f_f/Publickey)

POI=${kaitou}" wallet create -n ${ADO} --to-console" 

echo “----------------------------------------------------”
POU=${kaitou}" wallet import -n ${ADO} --private-key ${ADC}"
echo "----------------------------------------------------"


echo "-------------创建密码------------"
$POI >$f_f/Pass
sleep 1
echo "------------导入钱包-------------"
$POU
sleep 1
echo "-------------------密码---------------"
echo "$(cat $f_f/Pass)"
echo "地址:$ADO"
echo "私钥:$ADC"
echo "公钥:$ADE"
}

echo "###############list of configuration parameters#####################

#installation package path
forest_package=/root/forest.package

#Configuration file path
forest_dir=/root/forest.test

#Contract address
forest_contracts_dir=/root/forest.package/forest.contracts

#Configure the number of nodes
node_num=2
prods_num=1

#Producer name and public and private key
node1=147.124.218.114
node2=$this_ip
#If there is an internal network address, write the internal network address here, if not, write the public network address
node_n2=$this_ip 
producer2=$(cat $f_f/Address)
pubkey_K_2=$(cat $f_f/Publickey)
prikey_K_2=$(cat $f_f/Privatekey)
peer_array2=1



nod_svr_port=9878

nod_http_port=8888

rpc_http_port=8889

wallet_listenport=8900


hostssh_dir=/var/lib/forest_ssh" >/root/forest.test/param.ini

fn_get_cpu_info()

{

#echo -e "\n CPU Num is: "`grep -c 'model name' /proc/cpuinfo`

CpuTotal=`cat /proc/cpuinfo | grep processor | wc -l`

echo -e "\n Cpu is: ${CpuTotal} core "


}

fn_get_disk_info()

{

echo -e "\n Disk Information: "

DiskTotal=`df -h --total| grep total | awk '{print $2}'`

if [ "${DiskTotal: -1}" == "T" ]; then
    DiskTotal=${DiskTotal%?}
    if [ `awk -v num1=$DiskTotal -v num2=3.8  'BEGIN{print(num1>num2)?"0":"1"}'` -eq 0 ] && [  `awk -v num1=$DiskTotal -v num2=4  'BEGIN{print(num1<num2)?"0":"1"}'` -eq 0 ]; then
        DiskTotal=4
    fi
    DiskTotal=`awk -v x=1024 -v y=$DiskTotal 'BEGIN{printf "%.0f\n",x*y}'`
else
    DiskTotal=${DiskTotal%?}
fi

echo -e "\n Disk is: ${DiskTotal} GB "

}

fn_get_mem_info()

{

MemTotal=`free -m | grep Mem | awk '{print  $2}'`

MemTotal=$(($MemTotal/1000))

echo -e "\n Memory is: ${MemTotal} GB "

}

#-----------------------------------------------------------------------------------------------------------------

echo -e "\n -----------This Computer's Hardware Config Information is: -----------\n"

fn_get_disk_info

fn_get_cpu_info

fn_get_mem_info

echo -e "\n -----------End -----------\n"

UNIT_Value=$((CpuTotal << (64-8) | (MemTotal << (64-24)) | (DiskTotal << (64-48)) | 40))


zc(){
    ADDRESS=$(cat $f_f/Address)
    PRIVKEY=$(cat $f_f/Privatekey)
    PUBKEY=$(cat $f_f/Publickey)
    PASSWORD=$(cat $f_f/Pass)
    echo -e "# =============== = [ 解锁钱包并注册 ] ============================= #"
    un=${kaitou}" wallet unlock -n ${ADDRESS} -p ${PASSWORD}"
    $un
    echo $UNIT_Value
    register=${kaitou}"  push action fsio.sys regforest  '{\"account\":\"${ADDRESS}\", \"pubKey\":\"${PUBKEY}\", \"url\":\"${this_ip}:9878\",\"hwconfig\":\"${UNIT_Value}\"}' -p ${ADDRESS}@active" 
    echo $register
    $register
    echo "注册完成"
}

i=0
str='#'
ch=('|' '\' '-' '/')
index=0
while [ $i -le 25 ]
do
    printf "[%-25s][%d%%][%c]\r" $str $(($i*4)) ${ch[$index]}
    str+='#'
    let i++
    let index=i%4
    sleep 0.1
done
printf "\n"
echo "完成"

echo "-----------请选择----------"
echo "
[1] 导入钱包
[2] 注册节点
"
read -p "清选择服务：" shuchu
if [ 1 -eq $shuchu ];then
	qb
elif [ 2 -eq $shuchu ];then
	zc
else
	echo "输入错误"

fi


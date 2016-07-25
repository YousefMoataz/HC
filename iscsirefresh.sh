cd /pace
iscsimapping='/pacedata/iscsimapping';
iscsitargets='/pacedata/iscsitargets';
#/sbin/iscsiadm -m session --rescan &>/dev/null
needrescan=0;
while read -r  hostline ; do
 host=`echo $hostline | awk '{print $2}'`
 ping -c 1 -W 1 $host &>/dev/null
 if [ $? -eq 0 ]; then
  needrescan=1;
  hostpath=`ls /var/lib/iscsi/nodes/ | grep "$host"`;
  echo cat $iscsimapping  echo $host  grep notconnected 
  cat $iscsimapping |  grep "$host" | grep notconnected &>/dev/null
  if [ $? -eq 0 ]; then
   hostn=`cat $iscsitargets | grep $host | awk '{print $2}'`
   sed -i "/$hostn/ s/notconnected/newconnected/g" $iscsimapping;
  cat $iscsimapping
  fi
  cat $iscsimapping |  grep "$host" | grep newconnected &>/dev/null
  if [ $? -eq 0 ]; then
   echo here
   rm -rf /var/lib/iscsi/nodes/send_targets/$host* &>/dev/null
   hostiqn=`/sbin/iscsiadm -m discovery --portal $host --type sendtargets | awk '{print $2}'`
#   /sbin/iscsiadm -m node --targetname $hostiqn --portal $host -u
   /sbin/iscsiadm -m node --targetname $hostiqn --portal $host -l
   /sbin/iscsiadm -m session --rescan &>/dev/null
  fi
 else
  echo deleteing $host
  rm -rf /var/lib/iscsi/nodes/iqn.2016-03.com.${host}:t1 
  rm -rf /var/lib/iscsi/nodes/${host}* &>/dev/null
 fi
done < $iscsitargets
if [ $needrescan -eq 1 ]; then
# /sbin/iscsiadm -m session --rescan &>/dev/null
 sleep 1; 
fi
./listingtargets2.sh

#!/system/bin/bash

#Removal Beta v1.1 by Decad3nce
#Application:
application="Battery Tweak Script";
#End

RemoveAllFiles()
{
   mount -o remount,rw / /
   rm /system/bin/batt.sh;
   rm /system/bin/batt-cfg;
   rm /system/etc/batt.conf;
   rm /system/etc/batt-temp.conf;
   rm /system/bin/batt-diag;
   rm /system/etc/init.d/01BatteryTweak
   log "Removed $application";
   rm /system/bin/batt-rm.sh;
   mount -o remount,ro / /
   exit;
}

DontRemoveFiles()
{
   mount -o remount,rw / / 
   log "Canceled Removal of $application";
   mount -o remount,ro / /
   echo "Cancelled removing files"
   exit;
}

echo ""
echo ""
echo ""

echo "This tool will remove all traces of the Battery Tweak"
echo ""
echo "Are you sure that you want to go through with this?[y/n]"
read ANS

case $ANS in
           "y") RemoveAllFiles;;
           "n") DontRemoveFiles;;
             *) echo "Cancelled Removal of $application";;
esac

done

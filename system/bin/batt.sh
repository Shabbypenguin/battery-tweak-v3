#!/system/bin/sh

#Added support for the crespo/4g by Shabbypenguin
#Added Beta Code 1.0 for usb-ac charging variants by Decad3nce
#Battery Tweak Beta by collin_ph
#configurable options
#moved to /system/etc/batt.conf
. /system/etc/batt.conf
. /system/etc/batt-temp.conf

if [ "$enabled" -gt "0" ] 
 then
#if [ "$audio_fix" -gt "0" ]
#   then
#	 log "collin_ph: audiofix enabled, disabling stagefright"
#	 setprop media.stagefright.enable-player false
#	 else
#	 log "collin_ph: audiofix disabled, enabling stagefright"
#	 setprop media.stagefright.enable-player true
#fi
	  
 
 
#Initialization variables
#Dont mess with these.
CFSstate="unknown!"
charging_source="unknown!"
last_source="unknown";
batt_life=0;
current_polling_interval=5;
current_max_clock=0
bias=0;
last_bias=0;
last_capacity=0;
#End of init variables

#launchMOUNToptions()
#{
#log "collin_ph: remounting file systems $1"

#mount -o $1 / -t rootfs
#mount -o $1 /dev -t devpts
#mount -o $1 /proc -t proc
#mount -o $1 /sys -t sysfs
#mount -o $1 /mnt/asec -t tmpfs
#mount -o $1 /system -t yaffs2
#mount -o $1 /data -t yaffs2
#mount -o $1 /cache -t yaffs2
#mount -o $1 /mnt/sdcard -t vfat
#mount -o $1 /mnt/secure/asec -t vfat
#mount -o $1 /mnt/sdcard/.android_secure -t tmpfs
#}

# launchCFStweaks()
#{
# navPID=`pidof "com.google.android.apps.maps:driveabout" "com.google.android.apps.maps"`
# if [ "$navPID" ] 
 # then 
 # disableCFStweaks "Disabling CFS Tweaks, GPS Navigation detected.";
 # else
 # if [ "$CFSstate" != "enabled" ] 
 # then
 # mount -t debugfs none /sys/kernel/debug
 # log "collin_ph: Changed sched_features (CFS Tweaks Enabled)"
 # echo "NO_NEW_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
 # umount /sys/kernel/debug
 # CFSstate="enabled"
 # fi
# fi

# }
#disableCFStweaks()
# {
# if [ "$CFSstate" != "disabled" ]
# then
# mount -t debugfs none /sys/kernel/debug
# log "collin_ph: Changed sched_features $1"
# echo "NEW_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
# umount /sys/kernel/debug
# CFSstate="disabled"
# fi
# }

increase_battery()
{
log "collin_ph: Increasing Battery"
#New Performance Tweaks
mount -o remount,rw /dev/block/platform/s3c-sdhci.0/by-name/system /system
current_polling_interval=$polling_interval_on_battery;
echo 0 > /proc/sys/vm/swappiness
echo 0 > /proc/sys/vm/dirty_expire_centisecs
echo 0 > /proc/sys/vm/dirty_writeback_centisecs
echo 60 > /proc/sys/vm/dirty_background_ratio
echo 95 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $scaling_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $cpu_scheduler > /sys/block/mtdblock3/queue/scheduler
echo 95 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias

if [ "$OverHeatActive" = "0" ]
  then
	echo $max_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $min_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
fi

last_capacity=0;
current_max_clock=$max_freq_on_battery
mount -o remount,ro /dev/block/platform/s3c-sdhci.0/by-name/system /system
log "collin_ph: Done Increasing Battery"
}

increase_performanceUSB()
{
log "collin_ph: Increasing Performance For USB Charging"

#mount -o remount,rw /
current_polling_interval=$polling_interval_on_USBpower;
echo 30 > /proc/sys/vm/swappiness
echo 1500 > /proc/sys/vm/dirty_expire_centisecs
echo 250 > /proc/sys/vm/dirty_writeback_centisecs
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 40 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $scaling_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $cpu_scheduler > /sys/block/mtdblock3/queue/scheduler
echo 45 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias

if [ "$OverHeatActive" = "0" ]
  then
	echo $max_freq_on_USBpower > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $min_freq_on_USBpower > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
fi

last_capacity=0;
current_max_clock=$max_clock_on_USBpower
#mount -o remount,ro /
log "collin_ph: Done Increasing Performance on USB Charging"
}

increase_performance()
{
log "collin_ph: Increasing Performance"
#mount -o remount,rw /
current_polling_interval=$polling_interval_on_power;
echo 30 > /proc/sys/vm/swappiness
echo 3000 > /proc/sys/vm/dirty_expire_centisecs
echo 500 > /proc/sys/vm/dirty_writeback_centisecs
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 40 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $scaling_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $cpu_scheduler > /sys/block/mtdblock3/queue/scheduler
echo 50 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias

if [ "$OverHeatActive" = "0" ]
  then
	echo $max_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $min_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
fi

last_capacity=0;
current_max_clock=$max_clock_on_power
#mount -o remount,ro /
log "collin_ph: Done Increasing Performance"
}
set_powersave_bias()
{
    capacity=`expr $capacity '*' 10`
    bias=`expr 1000 "-" $capacity`
    bias=`expr $bias "/" $battery_divisor`
    bias=`echo $bias | awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}'`
    if [ "$bias" != "$last_bias" ]
       then
       log "collin_ph: Setting powersave bias to $bias"
       #mount -o remount,rw /
       echo $bias > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
       #mount -o remount,ro /
       last_bias=$bias;
      log "collin_ph: Done Setting powersave bias"
       
    fi

}

set_max_clock()
{
    temp=`expr 100 "-" $capacity`
		temp=`expr $temp \* $cpu_max_underclock_perc`
		temp=`expr $temp "/" 100`
		temp=`expr $temp \* $max_freq_on_battery`
		temp=`expr $temp "/" 100`
		temp=`expr $max_freq_on_battery "-" $temp`
    
    if [ "$temp" != "$current_max_clock" ]
       then
       current_max_clock=$temp
       log "collin_ph: Setting Max Clock to $temp";
       echo $temp > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
       log "collin_ph: Done Setting Max Clock";
    fi


}
#case $MOUNToptions in
#   "1") launchMOUNToptions remount,noatime,nodiratime;;
#     *) launchMOUNToptions remount,atime,diratime;;
#esac


while [ 1 ] 
do
charging_AC=$(cat /sys/class/power_supply/ac/online);
charging_USB=$(cat /sys/class/power_supply/usb/online);
capacity=$(cat /sys/class/power_supply/battery/capacity);
CurrentTemp=$(cat /sys/class/power_supply/battery/temp);


sleep $current_polling_interval
log "collin_ph: polling biatch";	    

#case $CFStweaks in
#   "1") launchCFStweaks;;
#     *) disableCFStweaks "CFS Tweaks Disabled";;
#esac

if [ "$charging_AC" = "1" ]
  then
     log "collin_ph status= Charging Source: 1=USB 2=AC 0=Battery"
     log "collin_ph status= Charging Source: charging_source = 2"
       case $charging_AC in
          "0") increase_battery;;
          "1") increase_performance;;
       esac


fi

if [ "$charging_USB" = "1" ]
  then
     log "collin_ph status= Charging Source: 1=USB 2=AC 0=Battery"
     log "collin_ph status= Charging Source: charging_source = 1"
       case $charging_USB in
          "0") increase_battery;;
          "1") increase_performanceUSB;;
       esac


fi


if [ "$charging_USB" = "0" ]
  then
   if [ "$charging_AC" = "0" ]
    then
     if [ "$capacity" != "$last_capacity" ]
      then
        last_capacity=$capacity
        log "collin_ph: status = Charging Source: charging_source=0"
      case $cpu_limiting_method in
       "1") set_max_clock;;
       "2") set_powersave_bias;;
      esac
     fi
   fi
fi

if [ "$MaxTempEnable" = "y" ]
  then
  if [ "$CurrentTemp" -gt "$MaxTemp" ]
	then
	mount -o remount,rw /dev/block/platform/s3c-sdhci.0/by-name/system /system
	echo "OverHeatActive=1" > /system/etc/batt-temp.conf
	mount -o remount,ro /dev/block/platform/s3c-sdhci.0/by-name/system /system
	echo $MaxFreqOverride > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $MinFreqOverride > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	log "collin_ph: Phone is Overheating, Max Frequencies override"
  else
	if [ "$OverHeatActive" != "0" ]
	      then
                mount -o remount,rw /dev/block/platform/s3c-sdhci.0/by-name/system /system
		echo "OverHeatActive=0" > /system/etc/batt-temp.conf
		mount -o remount,ro /dev/block/platform/s3c-sdhci.0/by-name/system /system
	fi
  fi
fi

done


fi #end here if enabled
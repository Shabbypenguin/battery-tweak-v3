#!/system/bin/sh


#Added Beta Code 1.0 for usb-ac charging variants by Decad3nce
#Battery Tweak Beta by collin_ph
#configurable options
#moved to /system/etc/batt.conf

. /system/etc/batt.conf
if "$enabled" -gt "0" > /dev/nul
 then
if "$audio_fix" -gt "0" > /dev/nul
   then
	 log "collin_ph: audiofix enabled, disabling stagefright"
	 setprop media.stagefright.enable-player false
	 else
	 log "collin_ph: audiofix disabled, enabling stagefright"
	 setprop media.stagefright.enable-player true
fi
	  
 
 
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

launchMOUNToptions()
{
log "collin_ph: remounting file systems $1"

mount -o $1 / -t rootfs
mount -o $1 /dev -t devpts
mount -o $1 /proc -t proc
mount -o $1 /sys -t sysfs
mount -o $1 /mnt/asec -t tmpfs
mount -o $1 /system -t yaffs2
mount -o $1 /data -t yaffs2
mount -o $1 /cache -t yaffs2
mount -o $1 /mnt/sdcard -t vfat
mount -o $1 /mnt/secure/asec -t vfat
mount -o $1 /mnt/sdcard/.android_secure -t tmpfs
}

launchCFStweaks()
{
navPID=`pidof "com.google.android.apps.maps:driveabout"`
if "$navPID" > /dev/nul
 then 
 disableCFStweaks "Disabling CFS Tweaks, GPS Navigation detected.";
 else
 if "$CFSstate" != "enabled" > /dev/nul
 then
 mount -t debugfs none /sys/kernel/debug
 log "collin_ph: Changed sched_features (CFS Tweaks Enabled)"
 echo "NO_NEW_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
 umount /sys/kernel/debug
 CFSstate="enabled"
 fi
fi

}
disableCFStweaks()
{
if "$CFSstate" != "disabled"> /dev/nul
then
mount -t debugfs none /sys/kernel/debug
log "collin_ph: Changed sched_features $1"
echo "NEW_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
umount /sys/kernel/debug
CFSstate="disabled"
fi
}

increase_battery()
{
log "collin_ph: Increasing Battery"
#New Performance Tweaks
mount -t rfs -o remount,rw /dev/block/stl9 /system
if $LEDfix > /dev/nul 
   then
   echo 0 > /sys/class/leds/amber/brightness
   echo 0 > /sys/class/leds/green/brightness
fi
current_polling_interval=$polling_interval_on_battery;
echo 0 > /proc/sys/vm/swappiness
echo 0 > /proc/sys/vm/dirty_expire_centisecs
echo 0 > /proc/sys/vm/dirty_writeback_centisecs
echo 60 > /proc/sys/vm/dirty_background_ratio
echo 95 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $max_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $min_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo 95 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
#echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
last_capacity=0;
current_max_clock=$max_freq_on_battery
mount -t rfs -o remount,ro /dev/block/stl9 /system
log "collin_ph: Done Increasing Battery"
}

increase_performanceUSB()
{
log "collin_ph: Increasing Performance For USB Charging"

mount -t rfs -o remount,rw /dev/block/stl9 /
current_polling_interval=$polling_interval_on_USBpower;
echo 30 > /proc/sys/vm/swappiness
echo 1500 > /proc/sys/vm/dirty_expire_centisecs
echo 250 > /proc/sys/vm/dirty_writeback_centisecs
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 40 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $max_freq_on_USBpower > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $min_freq_on_USBpower > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo 45 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
#echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
last_capacity=0;
current_max_clock=$max_clock_on_USBpower
mount -t rfs -o remount,ro /dev/block/stl9 /
log "collin_ph: Done Increasing Performance on USB Charging"
}

increase_performance()
{
log "collin_ph: Increasing Performance"
mount -t rfs -o remount,rw /dev/block/stl9 /
current_polling_interval=$polling_interval_on_power;
echo 30 > /proc/sys/vm/swappiness
echo 3000 > /proc/sys/vm/dirty_expire_centisecs
echo 500 > /proc/sys/vm/dirty_writeback_centisecs
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 40 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $max_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $min_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo 50 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
#echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
last_capacity=0;
current_max_clock=$max_clock_on_power
mount -t rfs -o remount,ro /dev/block/stl9 /
log "collin_ph: Done Increasing Performance"
}
set_powersave_bias()
{
    capacity=`expr $capacity '*' 10`
    bias=`expr 1000 "-" $capacity`
    bias=`expr $bias "/" $battery_divisor`
    bias=`echo $bias | awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}'`
    if "$bias" != "$last_bias" > /dev/nul
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
		temp=`expr $temp "*" $cpu_max_underclock_perc`
		temp=`expr $temp "/" 100`
		temp=`expr $temp "*" $max_freq_on_battery`
		temp=`expr $temp "/" 100`
		temp=`expr $max_freq_on_battery "-" $temp`
    
    if "$temp" != "$current_max_clock" > /dev/nul
       then
       current_max_clock=$temp
       log "collin_ph: Setting Max Clock to $temp";
       echo $temp > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
       log "collin_ph: Done Setting Max Clock";
    fi


}
case $MOUNToptions in
   "1") launchMOUNToptions remount,noatime,nodiratime;;
     *) launchMOUNToptions remount,atime,diratime;;
esac


while 1 > /dev/nul
do
charging_source=$(cat /sys/class/power_supply/battery/charging_source);
capacity=$(cat /sys/class/power_supply/battery/capacity);


sleep $current_polling_interval
	    

case $CFStweaks in
   "1") launchCFStweaks;;
     *) disableCFStweaks "CFS Tweaks Disabled";;
esac

if "$charging_source" != "$last_source" > /dev/nul
  then
     last_source=$charging_source;
     log "collin_ph status= Charging Source: 1=USB 2=AC 0=Battery"
     log "collin_ph status= Charging Source: charging_source=$charging_source"
       case $charging_source in
          "0") increase_battery;;
          "1") increase_performanceUSB;;
          "2") increase_performance;;
       esac


fi


if "$charging_source" = "0" > /dev/nul
  then
  if "$capacity" != "$last_capacity" > /dev/nul
    then
    last_capacity=$capacity
    log "collin_ph: status = Charging Source: charging_source=$charging_source"
    case $cpu_limiting_method in
       "1") set_max_clock;;
       "2") set_powersave_bias;;
    esac

  fi
fi

done


fi #end here if enabled













------------------------------------------------------
#old script
------------------------------------------------------
#!/system/bin/sh
echo "Starting up"

expr="busybox expr"
#configurable options
#moved to /system/etc/batt.conf

. /system/etc/batt.conf

#Initialization variables
#Dont mess with these.
status="unknown!"
last_status="unknown";
batt_life=0;
current_polling_interval=5;
current_max_clock=0
bias=0;
last_bias=0;
last_capacity=0;
#End of init variables
echo "Defining Functions"
increase_battery()
{
log "collin_ph: Increasing Battery"
mount -t rfs -o remount,rw /dev/block/stl9 /
current_polling_interval=$polling_interval_on_battery;
echo 0 > /proc/sys/vm/swappiness
echo 0 > /proc/sys/vm/dirty_expire_centisecs
echo 0 > /proc/sys/vm/dirty_writeback_centisecs
echo 60 > /proc/sys/vm/dirty_background_ratio
echo 95 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $max_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $min_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
#echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
last_capacity=0;
current_max_clock=$max_freq_on_battery
mount -t rfs -o remount,ro /dev/block/stl9 /system
log "collin_ph: Done Increasing Battery"
}

increase_performance()
{
log "collin_ph: Increasing Performance"
mount -t rfs -o remount,rw /dev/block/stl9 /
current_polling_interval=$polling_interval_on_power;
echo 30 > /proc/sys/vm/swappiness
echo 3000 > /proc/sys/vm/dirty_expire_centisecs
echo 500 > /proc/sys/vm/dirty_writeback_centisecs
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 40 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo $max_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $min_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo 50 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
#echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
last_capacity=0;
current_max_clock=$max_clock_on_power
mount -t rfs -o remount,ro /dev/block/stl9 /
log "collin_ph: Done Increasing Performance"
}
set_powersave_bias()
{
    capacity=`expr $capacity '*' 10`
    bias=`expr 1000 "-" $capacity`
    bias=`expr $bias "/" $battery_divisor`
    bias=`echo $bias | awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}'`
    if $expr "$bias" != "$last_bias" > /dev/nul 
       then
       log "collin_ph: Setting powersave bias to $bias"
       mount -t rfs -o remount,rw /dev/block/stl9 /
       #echo $bias > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
       mount -t rfs -o remount,ro /dev/block/stl9 /
       last_bias=$bias;
      log "collin_ph: Done Setting powersave bias"
       
    fi

}

set_max_clock()
{
    temp=`expr 100 "-" $capacity`
    temp=`expr $temp "/" $battery_divisor`
    temp=`expr $max_freq_on_battery "*" $temp`
    temp=`expr $temp "/" 100`
    temp=`expr $max_freq_on_battery "-" $temp`
    temp=`echo $temp | awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}'`

    if $expr "$temp" != "$current_max_clock" > /dev/nul 
       then
       current_max_clock=$temp
       log "collin_ph: Setting Max Clock to $temp";
       echo $temp > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
       log "collin_ph: Done Setting Max Clock";
    fi


}

while $expr 1 > /dev/nul 
do
status=$(cat /sys/class/power_supply/battery/status);
capacity=$(cat /sys/class/power_supply/battery/capacity);

sleep $current_polling_interval
if $expr "$status" != "$last_status" > /dev/nul 
  then
     last_status=$status;
       case $status in
          "Not charging") increase_battery;;
          *) increase_performance;;
       esac


fi


if $expr "$status" = "Not charging" > /dev/nul
  then
  if $expr "$capacity" != "$last_capacity"  > /dev/nul
    then
    last_capacity=$capacity
    log "collin_ph: status = $status"
    case $cpu_limiting_method in
       "1") set_max_clock;;
       "2") set_powersave_bias;;
    esac

  fi
fi

done

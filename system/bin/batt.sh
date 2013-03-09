#!/system/bin/bash


#Added Beta Code 1.0 for usb-ac charging variants by Decad3nce
#Battery Tweak Beta by collin_ph
#configurable options
#moved to /system/etc/batt.conf
. /system/etc/batt.conf
. /system/etc/batt-temp.conf

if [ "$enabled" -gt "0" ] 
 then
 
 
#Initialization variables
#Dont mess with these.
charging_source="unknown!"
last_source="unknown";
batt_life=0;
current_polling_interval=5;
current_max_clock=0
bias=0;
last_bias=0;
last_capacity=0;
#End of init variables

increase_battery()
{
log "Increasing Battery"
#New Performance Tweaks
mount -o remount,rw / /
current_polling_interval=$polling_interval_on_battery;
echo $scaling_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $cpu_scheduler > /sys/block/mmcblk0/queue/scheduler
echo 95 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias

if [ "$OverHeatActive" = "0" ]
  then
	echo $max_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $min_freq_on_battery > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
fi

last_capacity=0;
current_max_clock=$max_freq_on_battery
mount -o remount,ro / /
log "Done Increasing Battery"
}

increase_performanceUSB()
{
log "Increasing Performance For USB Charging"

mount -o remount,rw / /
current_polling_interval=$polling_interval_on_USBpower;
echo $scaling_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $cpu_scheduler > /sys/block/mmcblk0/queue/scheduler
echo 45 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias

if [ "$OverHeatActive" = "0" ]
  then
	echo $max_freq_on_USBpower > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $min_freq_on_USBpower > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
fi

last_capacity=0;
current_max_clock=$max_clock_on_USBpower
mount -o remount,ro / /
log "Done Increasing Performance on USB Charging"
}

increase_performance()
{
log "Increasing Performance"
mount -o remount,rw / /
current_polling_interval=$polling_interval_on_power;
echo $scaling_governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $cpu_scheduler > /sys/block/mmcblk0/queue/scheduler
echo 50 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias

if [ "$OverHeatActive" = "0" ]
  then
	echo $max_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $min_freq_on_power > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
fi

last_capacity=0;
current_max_clock=$max_clock_on_power
mount -o remount,rw / /
log "Done Increasing Performance"
}
set_powersave_bias()
{
    capacity=`expr $capacity '*' 10`
    bias=`expr 1000 "-" $capacity`
    bias=`expr $bias "/" $battery_divisor`
    bias=`echo $bias | awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}'`
    if [ "$bias" != "$last_bias" ]
       then
       log "Setting powersave bias to $bias"
       mount -o remount,rw / /
       echo $bias > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/powersave_bias
       mount -o remount,ro / /
       last_bias=$bias;
      log "Done Setting powersave bias"
       
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
       log "Setting Max Clock to $temp";
       echo $temp > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
       log "Done Setting Max Clock";
    fi


}

while [ 1 ] 
do
charging_AC=$(cat /sys/class/power_supply/ac/online);
charging_USB=$(cat /sys/class/power_supply/usb/online);
capacity=$(cat /sys/class/power_supply/battery/capacity);
CurrentTemp=$(cat /sys/class/power_supply/battery/temp);


sleep $current_polling_interval
log "polling biatch";	    


if [ "$charging_AC" = "1" ]
  then
     log "Status= Charging Source: 1=USB 2=AC 0=Battery"
     log "Status= Charging Source: charging_source = 2"
       case $charging_AC in
          "0") increase_battery;;
          "1") increase_performance;;
       esac


fi

if [ "$charging_USB" = "1" ]
  then
     log "Status= Charging Source: 1=USB 2=AC 0=Battery"
     log "Status= Charging Source: charging_source = 1"
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
        log "Status = Charging Source: charging_source=0"
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
	mount -o remount,rw /system /system
	echo "OverHeatActive=1" > /system/etc/batt-temp.conf
	echo $MaxFreqOverride > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $MinFreqOverride > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
	mount -o remount,ro / /
	log "Phone is Overheating, Max Frequencies override"
  else
	if [ "$OverHeatActive" != "0" ]
	      then
                mount -o remount,rw /system /system
				echo "OverHeatActive=0" > /system/etc/batt-temp.conf
				mount -o remount,ro /system /system
	fi
  fi
fi

done


fi #end here if enabled

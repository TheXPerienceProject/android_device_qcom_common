#! /vendor/bin/sh

# Copyright  2018 The XPerience Project
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The XPerience Project nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# NOTE: Set SchedAlessa as sched governor for supported platforms
# Also added msm8917 for future reference
# This file will be edited to make a better configuration.

#MSM8953 can be used for SDM450 platforms
function 8953_sched_eas_config()
{
    #governor settings
    echo 1 > /sys/devices/system/cpu/cpu0/online
    echo "schedalessa" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpufreq/schedalessa/up_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpufreq/schedalessa/down_rate_limit_us
	#configure schedutil too maybe some people wants it :P
    echo 0 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
    #set the hispeed_freq
    #echo 1401600 > /sys/devices/system/cpu/cpufreq/schedalessa/hispeed_freq
    #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
	# Our sched gov is not the same as 4.9 kernel
    #echo 85 > /sys/devices/system/cpu/cpufreq/schedalessa/hispeed_load

}

function 8917_sched_eas_config()
{
    #governor settings
    echo 1 > /sys/devices/system/cpu/cpu0/online
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpufreq/schedalessa/up_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpufreq/schedalessa/down_rate_limit_us
    #set the hispeed_freq
    #echo 1094400 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
    #default value for hispeed_load is 90, for 8917 it should be 85
    #echo 85 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
}


function 8937_sched_eas_config()
{
    # enable governor for perf cluster
    echo 1 > /sys/devices/system/cpu/cpu0/online
    echo "schedalessa" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedalessa/up_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedalessa/down_rate_limit_us
	#configure schedutil too maybe some people wants it :P
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    #set the hispeed_freq
    echo 1094400 > /sys/devices/system/cpu/cpu0/cpufreq/schedalessa/hispeed_freq
    #default value for hispeed_load is 90, for 8937 it should be 85
    echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/schedalessa/hispeed_load
    ## enable governor for power cluster
    echo 1 > /sys/devices/system/cpu/cpu4/online
    echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/schedalessa/up_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/schedalessa/down_rate_limit_us
	#configure schedutil too maybe some people wants it :P
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    #set the hispeed_freq
    #echo 768000 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
    #default value for hispeed_load is 90, for 8937 it should be 85
    #echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_load

}

function msm8226_config()
{
        echo 4 > /sys/module/lpm_levels/enable_low_power/l2
        echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/idle_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/idle_enabled
        echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/idle_enabled
        echo 1 > /sys/devices/system/cpu/cpu1/online
        echo 1 > /sys/devices/system/cpu/cpu2/online
        echo 1 > /sys/devices/system/cpu/cpu3/online
        echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
        echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
        echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
        echo 2 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
        echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
        echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
        echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
        echo 787200 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
        echo 300000 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
        echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
        echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        chown -h root.system /sys/devices/system/cpu/cpu1/online
        chown -h root.system /sys/devices/system/cpu/cpu2/online
        chown -h root.system /sys/devices/system/cpu/cpu3/online
        chmod -h 664 /sys/devices/system/cpu/cpu1/online
        chmod -h 664 /sys/devices/system/cpu/cpu2/online
        chmod -h 664 /sys/devices/system/cpu/cpu3/online
}

target=`getprop ro.board.platform`
device=`getprop ro.xpe.model`

function configure_zram_parameters() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    low_ram=`getprop ro.config.low_ram`

    # Zram disk - 75% for Go devices.
    # For 512MB Go device, size = 384MB, set same for Non-Go.
    # For 1GB Go device, size = 768MB, set same for Non-Go.
    # For >=2GB Non-Go device, size = 1GB
    # And enable lz4 zram compression for Go targets.
    # Some devices like Xiaomi have different variants
    # 2GB and 3gb others devices have variants of 1gb 2gb and 3gb
    # to make it more easy for all we can use this code extracted from CAF
    # Copyright (c) 2012-2013, 2016-2018, The Linux Foundation. All rights reserved.

    if [ "$low_ram" == "true" ]; then
        echo lz4 > /sys/block/zram0/comp_algorithm
    fi

    if [ -f /sys/block/zram0/disksize ]; then
        if [ $MemTotal -le 524288 ]; then
            echo 402653184 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 1048576 ]; then
            echo 805306368 > /sys/block/zram0/disksize
        else
            # Set Zram disk size=1GB for >=2GB Non-Go targets.
            echo 1073741824 > /sys/block/zram0/disksize
        fi
        mkswap /dev/block/zram0
        swapon /dev/block/zram0 -p 32758
    fi
}

function enable_memory_features()
{
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}
    if [ $MemTotal -le 2097152 ]; then
        #Enable B service adj transition for 2GB or less memory
        setprop ro.vendor.qti.sys.fw.bservice_enable true
        setprop ro.vendor.qti.sys.fw.bservice_limit 5
        setprop ro.vendor.qti.sys.fw.bservice_age 5000
        #Enable Delay Service Restart
        setprop ro.vendor.qti.am.reschedule_service true
    fi
}

case "$target" in
    "msm8226")
	msm8226_config
	configure_zram_parameters
	enable_memory_features
	setprop vendor.xperience.post_boot.parsed 8226
	;;
esac

case "$target" in
     "msm8917")
     #execute his EAS configuration
     8917_sched_eas_config
     #configure memory features
     enable_memory_features
     configure_zram_parameters
     #to know if this was executed
     setprop vendor.xperience.post_boot.parsed 8917
     ;;
esac

case "$target" in
     "msm8937")
     #execute his EAS configuration
     8937_sched_eas_config
     #configure memory features
     enable_memory_features
     configure_zram_parameters
     #to know if this was executed
     setprop vendor.xperience.post_boot.parsed 8937
     ;;
esac
case "$target" in
     "msm8953")
     #execute his EAS configuration
     8953_sched_eas_config
     #configure memory features
     enable_memory_features
     configure_zram_parameters
     #to know if this was executed
     setprop vendor.xperience.post_boot.parsed 8953
     ;;
esac

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

#first track board platform
board=`getprop ro.board.platform`
device=`getprop ro.xpe.model`

#MSM8953 can be used for SDM450 platforms
function 8953_sched_eas_config()
{
    #governor settings
    echo 1 > /sys/devices/system/cpu/cpu0/online
    echo "schedalessa" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
    #set the hispeed_freq
    echo 1401600 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
    #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
    echo 85 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
}

function 8917_sched_eas_config()
{
    #governor settings
    echo 1 > /sys/devices/system/cpu/cpu0/online
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
    #set the hispeed_freq
    echo 1094400 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
    #default value for hispeed_load is 90, for 8917 it should be 85
    echo 85 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
}


function 8937_sched_eas_config()
{
    # enable governor for perf cluster
    echo 1 > /sys/devices/system/cpu/cpu0/online
    echo "schedalessa" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/rate_limit_us
    #set the hispeed_freq
    echo 1094400 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
    #default value for hispeed_load is 90, for 8937 it should be 85
    echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_load
    ## enable governor for power cluster
    echo 1 > /sys/devices/system/cpu/cpu4/online
    echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/rate_limit_us
    #set the hispeed_freq
    echo 768000 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
    #default value for hispeed_load is 90, for 8937 it should be 85
    echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_load

}

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


if [ $board == "msm8917" ]; then
              #execute his EAS configuration
              msm8917_sched_eas_config
              #configure memory features
              enable_memory_features
              #to know if this was executed
              setprop vendor.xperience.post_boot.parsed 1
fi
if [ $board == "msm8937" ]; then
              #execute his EAS configuration
              msm8937_sched_eas_config
              #configure memory features
              enable_memory_features
              #to know if this was executed
              setprop vendor.xperience.post_boot.parsed 1
fi
if [ $board == "msm8953" ]; then
              #execute his EAS configuration
              msm8953_sched_eas_config
      if [ $device == "mido" ]; then
        #configure memory features
        enable_memory_features
      fi
      #to know if this was executed
      setprop vendor.xperience.post_boot.parsed 1
fi

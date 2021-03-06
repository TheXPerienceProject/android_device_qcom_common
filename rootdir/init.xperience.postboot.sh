#! /vendor/bin/sh

# Copyright  2018-2019-2020 The XPerience Project
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
function 8953_sched_eas_config() {

  #if the kernel version >=4.9,use the schedutil governor
  KernelVersionStr=$(cat /proc/sys/kernel/osrelease)
  KernelVersionS=${KernelVersionStr:2:2}
  KernelVersionA=${KernelVersionStr:0:1}
  KernelVersionB=${KernelVersionS%.*}

  if [ $KernelVersionA -ge 4 ] && [ $KernelVersionB -ge 9 ]; then
    if [ "$gov" = "schedalessa" ]; then
      #governor settings
      echo 1>sys/devices/system/cpu/cpu0/online
      echo "schedalessa" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0>sys/devices/system/cpu/cpufreq/schedalessa/rate_limit_us
      #set the hispeed_freq
      echo 1401600>sys/devices/system/cpu/cpufreq/schedalessa/hispeed_freq
      #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
      echo 85>sys/devices/system/cpu/cpufreq/schedalessa/hispeed_load
    else
      #governor settings
      echo 1>sys/devices/system/cpu/cpu0/online
      echo "schedutil" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0>sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
      #set the hispeed_freq
      echo 1401600>sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
      #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
      echo 85>sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
    fi
  else
    #detect if we have SchedAlessa if not use SchedUtil configuration
    if [ "$gov" = "schedalessa" ]; then
      #governor settings schedalessa
      echo 1>sys/devices/system/cpu/cpu0/online
      echo "schedalessa" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0>sys/devices/system/cpu/cpufreq/schedalessa/up_rate_limit_us
      echo 0>sys/devices/system/cpu/cpufreq/schedalessa/down_rate_limit_us
      #BigCluster
      echo 1>sys/devices/system/cpu/cpu4/online
      echo "schedalessa" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
      echo 0>sys/devices/system/cpu/cpu4/cpufreq/schedutil/rate_limit_us
      echo 1363200>sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
    else
      #governor settings schedutil
      echo 1>sys/devices/system/cpu/cpu0/online
      echo "schedutil" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0>sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
      echo 0>sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
      echo 0>sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
      #set the hispeed_freq
      echo 1401600>sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
      #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
      echo 85>sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
      echo 1>sys/devices/system/cpu/cpu4/online
      echo "schedutil" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
      echo 0>sys/devices/system/cpu/cpu4/cpufreq/schedutil/rate_limit_us
      echo 1401600>sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
    fi
  fi

  setprop vendor.xperience.easkernelversion $KernelVersionA.$KernelVersionB

  #init task load, restrict wakeups to preferred cluster
  echo 15>proc/sys/kernel/sched_init_task_load
  #force set min freq cuz in some weird cases that is set to 1ghz
  echo 652800>sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  # force set max freq due to some random bug where is setting max freq as 1.6ghz
  echo 2016000>sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

  # Bring up all cores online
  echo 1>sys/devices/system/cpu/cpu1/online
  echo 1>sys/devices/system/cpu/cpu2/online
  echo 1>sys/devices/system/cpu/cpu3/online
  echo 1>sys/devices/system/cpu/cpu4/online
  echo 1>sys/devices/system/cpu/cpu5/online
  echo 1>sys/devices/system/cpu/cpu6/online
  echo 1>sys/devices/system/cpu/cpu7/online

  # Enable low power modes
  echo 0>sys/module/lpm_levels/parameters/sleep_disabled

  # choose idle CPU for top app tasks
  echo 1>dev/stune/top-app/schedtune.prefer_idle
  echo 1>dev/stune/top-app/schedtune.sched_boost

  #Enable Schedtune boost
  echo 1>dev/stune/schedtune.boost
}

function 8917_sched_eas_config() {
  #governor settings schedalessa
  echo 1>sys/devices/system/cpu/cpu0/online
  echo "schedutil" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0>sys/devices/system/cpu/cpufreq/schedalessa/up_rate_limit_us
  echo 0>sys/devices/system/cpu/cpufreq/schedalessa/down_rate_limit_us

  #governor settings schedutil
  echo 1>sys/devices/system/cpu/cpu0/online
  echo "schedutil" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0>sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
  #set the hispeed_freq
  echo 1094400>sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
  #default value for hispeed_load is 90, for 8917 it should be 85
  echo 85>sys/devices/system/cpu/cpufreq/schedutil/hispeed_load

}

function 8937_sched_eas_config() {
  # enable governor for perf cluster schedalessa
  echo 1>sys/devices/system/cpu/cpu0/online
  echo "schedalessa" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/schedalessa/up_rate_limit_us
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/schedalessa/down_rate_limit_us
  #configure schedutil too maybe some people wants it :P
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
  #set the hispeed_freq
  echo 1094400>sys/devices/system/cpu/cpu0/cpufreq/schedalessa/hispeed_freq
  #default value for hispeed_load is 90, for 8937 it should be 85
  echo 85>sys/devices/system/cpu/cpu0/cpufreq/schedalessa/hispeed_load
  ## enable governor for power cluster
  echo 1>sys/devices/system/cpu/cpu4/online
  echo "schedutil" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
  echo 0>sys/devices/system/cpu/cpu4/cpufreq/schedalessa/up_rate_limit_us
  echo 0>sys/devices/system/cpu/cpu4/cpufreq/schedalessa/down_rate_limit_us
  #configure schedutil too maybe some people wants it :P
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us

  # enable governor for perf cluster schedutil
  echo 1>sys/devices/system/cpu/cpu0/online
  echo "schedutil" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/schedutil/rate_limit_us
  #set the hispeed_freq
  echo 1094400>sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
  #default value for hispeed_load is 90, for 8937 it should be 85
  echo 85>sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_load
  ## enable governor for power cluster
  echo 1>sys/devices/system/cpu/cpu4/online
  echo "schedutil" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
  echo 0>sys/devices/system/cpu/cpu4/cpufreq/schedutil/rate_limit_us
  #set the hispeed_freq
  echo 768000>sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
  #default value for hispeed_load is 90, for 8937 it should be 85
  echo 85>sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_load

}
############ HMP #######################
function 8953_sched_dcvs_hmp() {
  #scheduler settings
  echo 3>proc/sys/kernel/sched_window_stats_policy
  echo 3>proc/sys/kernel/sched_ravg_hist_size
  #task packing settings
  echo 0>sys/devices/system/cpu/cpu0/sched_static_cpu_pwr_cost
  echo 0>sys/devices/system/cpu/cpu1/sched_static_cpu_pwr_cost
  echo 0>sys/devices/system/cpu/cpu2/sched_static_cpu_pwr_cost
  echo 0>sys/devices/system/cpu/cpu3/sched_static_cpu_pwr_cost
  echo 0>sys/devices/system/cpu/cpu4/sched_static_cpu_pwr_cost
  echo 0>sys/devices/system/cpu/cpu5/sched_static_cpu_pwr_cost
  echo 0>sys/devices/system/cpu/cpu6/sched_static_cpu_pwr_cost
  echo 0>sys/devices/system/cpu/cpu7/sched_static_cpu_pwr_cost
  # spill load is set to 100% by default in the kernel
  echo 3>proc/sys/kernel/sched_spill_nr_run
  # Apply inter-cluster load balancer restrictions
  echo 1>proc/sys/kernel/sched_restrict_cluster_spill
  # set sync wakee policy tunable
  echo 1>proc/sys/kernel/sched_prefer_sync_wakee_to_waker

  #governor settings
  echo 1>sys/devices/system/cpu/cpu0/online
  echo "interactive" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "19000 1401600:39000" >sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
  echo 85>sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
  echo 20000>sys/devices/system/cpu/cpufreq/interactive/timer_rate
  echo 1401600>sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
  echo 0>sys/devices/system/cpu/cpufreq/interactive/io_is_busy
  echo "85 1401600:80" >sys/devices/system/cpu/cpufreq/interactive/target_loads
  echo 39000>sys/devices/system/cpu/cpufreq/interactive/min_sample_time
  echo 40000>sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor
  echo 19>proc/sys/kernel/sched_upmigrate_min_nice
  # Enable sched guided freq control
  echo 1>sys/devices/system/cpu/cpufreq/interactive/use_sched_load
  echo 1>sys/devices/system/cpu/cpufreq/interactive/use_migration_notif
  echo 200000>proc/sys/kernel/sched_freq_inc_notify
  echo 200000>proc/sys/kernel/sched_freq_dec_notify

  # init task load, restrict wakeups to preferred cluster
  echo 15>proc/sys/kernel/sched_init_task_load
}

function 8917_sched_dcvs_hmp() {
  # HMP scheduler settings
  echo 3>proc/sys/kernel/sched_window_stats_policy
  echo 3>proc/sys/kernel/sched_ravg_hist_size
  echo 1>proc/sys/kernel/sched_restrict_tasks_spread
  # HMP Task packing settings
  echo 20>proc/sys/kernel/sched_small_task
  echo 30>sys/devices/system/cpu/cpu0/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu1/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu2/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu3/sched_mostly_idle_load

  echo 3>sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run

  echo 0>sys/devices/system/cpu/cpu0/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu1/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu2/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu3/sched_prefer_idle

  echo 1>sys/devices/system/cpu/cpu0/online
  echo "interactive" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "19000 1094400:39000" >sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
  echo 85>sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
  echo 20000>sys/devices/system/cpu/cpufreq/interactive/timer_rate
  echo 1094400>sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
  echo 0>sys/devices/system/cpu/cpufreq/interactive/io_is_busy
  echo "1 960000:85 1094400:90" >sys/devices/system/cpu/cpufreq/interactive/target_loads
  echo 40000>sys/devices/system/cpu/cpufreq/interactive/min_sample_time
  echo 40000>sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor

  # Enable sched guided freq control
  echo 1>sys/devices/system/cpu/cpufreq/interactive/use_sched_load
  echo 1>sys/devices/system/cpu/cpufreq/interactive/use_migration_notif
  echo 50000>proc/sys/kernel/sched_freq_inc_notify
  echo 50000>proc/sys/kernel/sched_freq_dec_notify
}

function 8937_sched_dcvs_hmp() {
  # HMP scheduler settings
  echo 3>proc/sys/kernel/sched_window_stats_policy
  echo 3>proc/sys/kernel/sched_ravg_hist_size
  # HMP Task packing settings
  echo 20>proc/sys/kernel/sched_small_task
  echo 30>sys/devices/system/cpu/cpu0/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu1/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu2/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu3/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu4/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu5/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu6/sched_mostly_idle_load
  echo 30>sys/devices/system/cpu/cpu7/sched_mostly_idle_load

  echo 3>sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu4/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu5/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu6/sched_mostly_idle_nr_run
  echo 3>sys/devices/system/cpu/cpu7/sched_mostly_idle_nr_run

  echo 0>sys/devices/system/cpu/cpu0/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu1/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu2/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu3/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu4/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu5/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu6/sched_prefer_idle
  echo 0>sys/devices/system/cpu/cpu7/sched_prefer_idle
  # enable governor for perf cluster
  echo 1>sys/devices/system/cpu/cpu0/online
  echo "interactive" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "19000 1094400:39000" >sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
  echo 85>sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
  echo 20000>sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
  echo 1094400>sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
  echo 0>sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
  echo "1 960000:85 1094400:90 1344000:80" >sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
  echo 40000>sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
  echo 40000>sys/devices/system/cpu/cpu0/cpufreq/interactive/sampling_down_factor

  # enable governor for power cluster
  echo 1>sys/devices/system/cpu/cpu4/online
  echo "interactive" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
  echo 39000>sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
  echo 90>sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
  echo 20000>sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
  echo 768000>sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
  echo 0>sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
  echo "1 768000:90" >sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
  echo 40000>sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
  echo 40000>sys/devices/system/cpu/cpu4/cpufreq/interactive/sampling_down_factor

  # Enable sched guided freq control
  echo 1>sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
  echo 1>sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
  echo 1>sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
  echo 1>sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
  echo 50000>proc/sys/kernel/sched_freq_inc_notify
  echo 50000>proc/sys/kernel/sched_freq_dec_notify

}

function msm8226_config() {
  echo 4>sys/module/lpm_levels/enable_low_power/l2
  echo 1>sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
  echo 1>sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
  echo 1>sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
  echo 1>sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
  echo 1>sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
  echo 1>sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
  echo 1>sys/module/msm_pm/modes/cpu1/power_collapse/idle_enabled
  echo 1>sys/module/msm_pm/modes/cpu2/power_collapse/idle_enabled
  echo 1>sys/module/msm_pm/modes/cpu3/power_collapse/idle_enabled
  echo 1>sys/devices/system/cpu/cpu1/online
  echo 1>sys/devices/system/cpu/cpu2/online
  echo 1>sys/devices/system/cpu/cpu3/online
  echo 50000>sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
  echo 90>sys/devices/system/cpu/cpufreq/ondemand/up_threshold
  echo 1>sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
  echo 2>sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
  echo 10>sys/devices/system/cpu/cpufreq/ondemand/down_differential
  echo 70>sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
  echo 10>sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
  echo 787200>sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
  echo 300000>sys/devices/system/cpu/cpufreq/ondemand/sync_freq
  echo 80>sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
  chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
  chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  chown -h root.system /sys/devices/system/cpu/cpu1/online
  chown -h root.system /sys/devices/system/cpu/cpu2/online
  chown -h root.system /sys/devices/system/cpu/cpu3/online
  chmod -h 664 /sys/devices/system/cpu/cpu1/online
  chmod -h 664 /sys/devices/system/cpu/cpu2/online
  chmod -h 664 /sys/devices/system/cpu/cpu3/online
  #Configure intelimm by default to avoid lags

  echo 1190400 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
  echo 1190400 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
  echo 192000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  echo "intellidemand" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  #  start mpdecision
  #enable doubletap2wake
  echo 1 >/sys/android_touch/doubletap2wake
  # force zram on lz4
  echo lz4 >/sys/block/zram0/comp_algorithm

}

function sdm660_configuration() {

  #execute his EAS configuration
  if [ "$gov" = "schedutil" -o "$gov" = "schedalessa" ]; then
    # configure governor settings for little cluster
    echo 1>sys/devices/system/cpu/cpu0/online
    echo "schedutil" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 633600>sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    # configure governor settings for big cluster
    echo 1>sys/devices/system/cpu/cpu4/online
    echo "schedalessa" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 1113600>sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    #extra configs for SchedAlessa and SchedUtil
    echo 500>sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 20000>sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    echo 500>sys/devices/system/cpu/cpu0/cpufreq/schedalessa/up_rate_limit_us
    echo 20000>sys/devices/system/cpu/cpu0/cpufreq/schedalessa/down_rate_limit_us
    echo 500>sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us
    echo 20000>sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us
    echo 500>sys/devices/system/cpu/cpu4/cpufreq/schedalessa/up_rate_limit_us
    echo 20000>sys/devices/system/cpu/cpu4/cpufreq/schedalessa/down_rate_limit_us

    echo 1>proc/sys/kernel/sched_walt_rotate_big_tasks
  else
    # configure governor settings for little cluster
    echo 1>sys/devices/system/cpu/cpu0/online
    echo "schedutil" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 633600>sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    # configure governor settings for big cluster
    echo 1>sys/devices/system/cpu/cpu4/online
    echo "schedutil" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 1113600>sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    #extra configs for SchedAlessa and SchedUtil
    echo 500>sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 20000>sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    echo 500>sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us
    echo 20000>sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us
    echo 1>proc/sys/kernel/sched_walt_rotate_big_tasks

  fi

  if [ "$gov" = "interactive" ]; then
    # online CPU0
    echo 1>sys/devices/system/cpu/cpu0/online
    # configure governor settings for little cluster
    echo "interactive" >sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 1>sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
    echo 1>sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
    echo "19000 1401600:39000" >sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
    echo 90>sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
    echo 20000>sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
    echo 1401600>sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
    echo 0>sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
    echo "85 1747200:95" >sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
    echo 39000>sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
    echo 0>sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
    echo 633600>sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1>sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif
    echo 1>sys/devices/system/cpu/cpu0/cpufreq/interactive/fast_ramp_down

    # online CPU4
    echo 1>sys/devices/system/cpu/cpu4/online
    # configure governor settings for big cluster
    echo "interactive" >sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 1>sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
    echo 1>sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
    echo "19000 1401600:39000" >sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
    echo 90>sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
    echo 20000>sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
    echo 1401600>sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
    echo 0>sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
    echo "85 1401600:90 2150400:95" >sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
    echo 39000>sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
    echo 59000>sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
    echo 1113600>sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
    echo 1>sys/devices/system/cpu/cpu4/cpufreq/interactive/ignore_hispeed_on_notif
    echo 1>sys/devices/system/cpu/cpu4/cpufreq/interactive/fast_ramp_down

  fi

  echo 2>sys/devices/system/cpu/cpu4/core_ctl/min_cpus
  echo 60>sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
  echo 30>sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
  echo 100>sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
  echo 1>sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
  echo 4>sys/devices/system/cpu/cpu4/core_ctl/task_thres

  # Setting b.L scheduler parameters
  echo 96>proc/sys/kernel/sched_upmigrate
  echo 90>proc/sys/kernel/sched_downmigrate
  echo 140>proc/sys/kernel/sched_group_upmigrate
  echo 120>proc/sys/kernel/sched_group_downmigrate
  echo 0>proc/sys/kernel/sched_select_prev_cpu_us
  echo 400000>proc/sys/kernel/sched_freq_inc_notify
  echo 400000>proc/sys/kernel/sched_freq_dec_notify
  echo 5>proc/sys/kernel/sched_spill_nr_run
  echo 1>proc/sys/kernel/sched_restrict_cluster_spill
  echo 100000>proc/sys/kernel/sched_short_burst_ns
  echo 1>proc/sys/kernel/sched_prefer_sync_wakee_to_waker
  echo 20>proc/sys/kernel/sched_small_wakee_task_load

  # cpuset settings
  echo 0-1 >/dev/cpuset/background/cpus
  echo 0-2 >/dev/cpuset/system-background/cpus
  echo 0-3 >/dev/cpuset/restricted/cpus

  # Enable bus-dcvs
  for cpubw in /sys/class/devfreq/*qcom,cpubw*; do
    echo "bw_hwmon" >$cpubw/governor
    echo 50 >$cpubw/polling_interval
    echo 762 >$cpubw/min_freq
    echo "1525 3143 5859 7759 9887 10327 11863 13763" >$cpubw/bw_hwmon/mbps_zones
    echo 4 >$cpubw/bw_hwmon/sample_ms
    echo 85 >$cpubw/bw_hwmon/io_percent
    echo 100 >$cpubw/bw_hwmon/decay_rate
    echo 50 >$cpubw/bw_hwmon/bw_step
    echo 20 >$cpubw/bw_hwmon/hist_memory
    echo 0 >$cpubw/bw_hwmon/hyst_length
    echo 80 >$cpubw/bw_hwmon/down_thres
    echo 0 >$cpubw/bw_hwmon/low_power_ceil_mbps
    echo 34 >$cpubw/bw_hwmon/low_power_io_percent
    echo 20 >$cpubw/bw_hwmon/low_power_delay
    echo 0 >$cpubw/bw_hwmon/guard_band_mbps
    echo 250 >$cpubw/bw_hwmon/up_scale
    echo 1600 >$cpubw/bw_hwmon/idle_mbps
  done

  for memlat in /sys/class/devfreq/*qcom,memlat-cpu*; do
    echo "mem_latency" >$memlat/governor
    echo 10 >$memlat/polling_interval
    echo 400 >$memlat/mem_latency/ratio_ceil
  done
  echo "cpufreq" >/sys/class/devfreq/soc:qcom,mincpubw/governor

}

####SDM 660 ###

function sm6150_configuration() {
  #those values will be changed in some months until I get a device for it
  #Apply settings for sm6150
  # Set the default IRQ affinity to the silver cluster. When a
  # CPU is isolated/hotplugged, the IRQ affinity is adjusted
  # to one of the CPU from the default IRQ affinity mask.
  echo 3f >/proc/irq/default_smp_affinity

  if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=$(cat /sys/devices/soc0/soc_id)
  else
    soc_id=$(cat /sys/devices/system/soc/soc0/id)
  fi

  case "$soc_id" in
  "355" | "369" | "377" | "380" | "384")
    target_type=$(getprop ro.hardware.type)
    if [ "$target_type" == "automotive" ]; then
      # update frequencies
      #configure_sku_parameters
      sku_identified=$(getprop vendor.sku_identified)
    else
      sku_identified=0
    fi
    # Core control parameters on silver
    echo 0 0 0 0 1 1 >/sys/devices/system/cpu/cpu0/core_ctl/not_preferred
    echo 4 >/sys/devices/system/cpu/cpu0/core_ctl/min_cpus
    echo 60 >/sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
    echo 40 >/sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
    echo 100 >/sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
    echo 0 >/sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster
    echo 8 >/sys/devices/system/cpu/cpu0/core_ctl/task_thres
    echo 0 >/sys/devices/system/cpu/cpu6/core_ctl/enable

    # Setting b.L scheduler parameters
    # default sched up and down migrate values are 90 and 85
    echo 65 >/proc/sys/kernel/sched_downmigrate
    echo 71 >/proc/sys/kernel/sched_upmigrate
    # default sched up and down migrate values are 100 and 95
    echo 85 >/proc/sys/kernel/sched_group_downmigrate
    echo 100 >/proc/sys/kernel/sched_group_upmigrate
    echo 1 >/proc/sys/kernel/sched_walt_rotate_big_tasks

    # colocation v3 settings
    echo 740000 >/proc/sys/kernel/sched_little_cluster_coloc_fmin_khz

    # configure governor settings for little cluster
    echo "schedutil" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 >/sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 0 >/sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    echo 1209600 >/sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
    if [ $sku_identified != 1 ]; then
      echo 576000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    fi

    # configure governor settings for big cluster
    echo "schedutil" >/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
    echo 0 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/up_rate_limit_us
    echo 0 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/down_rate_limit_us
    echo 1209600 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_freq
    if [ $sku_identified != 1 ]; then
      echo 768000 >/sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq
    fi

    # sched_load_boost as -6 is equivalent to target load as 85. It is per cpu tunable.
    echo -6 >/sys/devices/system/cpu/cpu6/sched_load_boost
    echo -6 >/sys/devices/system/cpu/cpu7/sched_load_boost
    echo 85 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_load

    echo "0:1209600" >/sys/module/cpu_boost/parameters/input_boost_freq
    echo 40 >/sys/module/cpu_boost/parameters/input_boost_ms

    # Set Memory parameters
    configure_memory_parameters

    # Enable bus-dcvs
    for device in /sys/devices/platform/soc; do
      for cpubw in $device/*cpu-cpu-llcc-bw/devfreq/*cpu-cpu-llcc-bw; do
        echo "bw_hwmon" >$cpubw/governor
        echo 50 >$cpubw/polling_interval
        echo "2288 4577 7110 9155 12298 14236" >$cpubw/bw_hwmon/mbps_zones
        echo 4 >$cpubw/bw_hwmon/sample_ms
        echo 68 >$cpubw/bw_hwmon/io_percent
        echo 20 >$cpubw/bw_hwmon/hist_memory
        echo 0 >$cpubw/bw_hwmon/hyst_length
        echo 80 >$cpubw/bw_hwmon/down_thres
        echo 0 >$cpubw/bw_hwmon/guard_band_mbps
        echo 250 >$cpubw/bw_hwmon/up_scale
        echo 1600 >$cpubw/bw_hwmon/idle_mbps
      done

      for llccbw in $device/*cpu-llcc-ddr-bw/devfreq/*cpu-llcc-ddr-bw; do
        echo "bw_hwmon" >$llccbw/governor
        echo 40 >$llccbw/polling_interval
        echo "1144 1720 2086 2929 3879 5931 6881" >$llccbw/bw_hwmon/mbps_zones
        echo 4 >$llccbw/bw_hwmon/sample_ms
        echo 68 >$llccbw/bw_hwmon/io_percent
        echo 20 >$llccbw/bw_hwmon/hist_memory
        echo 0 >$llccbw/bw_hwmon/hyst_length
        echo 80 >$llccbw/bw_hwmon/down_thres
        echo 0 >$llccbw/bw_hwmon/guard_band_mbps
        echo 250 >$llccbw/bw_hwmon/up_scale
        echo 1600 >$llccbw/bw_hwmon/idle_mbps
      done

      #Enable mem_latency governor for L3, LLCC, and DDR scaling
      for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat; do
        echo "mem_latency" >$memlat/governor
        echo 10 >$memlat/polling_interval
        echo 400 >$memlat/mem_latency/ratio_ceil
      done

      #Gold L3 ratio ceil
      echo 4000 >/sys/class/devfreq/soc:qcom,cpu6-cpu-l3-lat/mem_latency/ratio_ceil

      #Enable cdspl3 governor for L3 cdsp nodes
      for l3cdsp in $device/*cdsp-cdsp-l3-lat/devfreq/*cdsp-cdsp-l3-lat; do
        echo "cdspl3" >$l3cdsp/governor
      done

      #Enable compute governor for gold latfloor
      for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*; do
        echo "compute" >$latfloor/governor
        echo 10 >$latfloor/polling_interval
      done

    done
    # cpuset parameters
    echo 0-5 >/dev/cpuset/background/cpus
    echo 0-5 >/dev/cpuset/system-background/cpus

    # Turn off scheduler boost at the end
    echo 0 >/proc/sys/kernel/sched_boost

    # Turn on sleep modes.
    echo 0 >/sys/module/lpm_levels/parameters/sleep_disabled
    ;;
  esac

  #Apply settings for moorea
  case "$soc_id" in
  "365" | "366")

    # Core control parameters on silver
    echo 0 0 0 0 1 1 >/sys/devices/system/cpu/cpu0/core_ctl/not_preferred
    echo 4 >/sys/devices/system/cpu/cpu0/core_ctl/min_cpus
    echo 60 >/sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
    echo 40 >/sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
    echo 100 >/sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
    echo 0 >/sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster
    echo 8 >/sys/devices/system/cpu/cpu0/core_ctl/task_thres
    echo 0 >/sys/devices/system/cpu/cpu6/core_ctl/enable

    # Setting b.L scheduler parameters
    # default sched up and down migrate values are 71 and 65
    echo 65 >/proc/sys/kernel/sched_downmigrate
    echo 71 >/proc/sys/kernel/sched_upmigrate
    # default sched up and down migrate values are 100 and 95
    echo 85 >/proc/sys/kernel/sched_group_downmigrate
    echo 100 >/proc/sys/kernel/sched_group_upmigrate
    echo 1 >/proc/sys/kernel/sched_walt_rotate_big_tasks

    #colocation v3 settings
    echo 740000 >/proc/sys/kernel/sched_little_cluster_coloc_fmin_khz

    # configure governor settings for little cluster
    echo "schedutil" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 >/sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 0 >/sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    echo 1248000 >/sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
    echo 576000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    # configure governor settings for big cluster
    echo "schedutil" >/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
    echo 0 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/up_rate_limit_us
    echo 0 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/down_rate_limit_us
    echo 1324600 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_freq
    echo 652800 >/sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # sched_load_boost as -6 is equivalent to target load as 85. It is per cpu tunable.
    echo -6 >/sys/devices/system/cpu/cpu6/sched_load_boost
    echo -6 >/sys/devices/system/cpu/cpu7/sched_load_boost
    echo 85 >/sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_load

    echo "0:1248000" >/sys/module/cpu_boost/parameters/input_boost_freq
    echo 40 >/sys/module/cpu_boost/parameters/input_boost_ms

    # Set Memory parameters
    configure_memory_parameters

    # Enable bus-dcvs
    for device in /sys/devices/platform/soc; do
      for cpubw in $device/*cpu-cpu-llcc-bw/devfreq/*cpu-cpu-llcc-bw; do
        echo "bw_hwmon" >$cpubw/governor
        echo 50 >$cpubw/polling_interval
        echo "2288 4577 7110 9155 12298 14236" >$cpubw/bw_hwmon/mbps_zones
        echo 4 >$cpubw/bw_hwmon/sample_ms
        echo 68 >$cpubw/bw_hwmon/io_percent
        echo 20 >$cpubw/bw_hwmon/hist_memory
        echo 0 >$cpubw/bw_hwmon/hyst_length
        echo 80 >$cpubw/bw_hwmon/down_thres
        echo 0 >$cpubw/bw_hwmon/guard_band_mbps
        echo 250 >$cpubw/bw_hwmon/up_scale
        echo 1600 >$cpubw/bw_hwmon/idle_mbps
      done

      for llccbw in $device/*cpu-llcc-ddr-bw/devfreq/*cpu-llcc-ddr-bw; do
        echo "bw_hwmon" >$llccbw/governor
        echo 40 >$llccbw/polling_interval
        echo "1144 1720 2086 2929 3879 5931 6881" >$llccbw/bw_hwmon/mbps_zones
        echo 4 >$llccbw/bw_hwmon/sample_ms
        echo 68 >$llccbw/bw_hwmon/io_percent
        echo 20 >$llccbw/bw_hwmon/hist_memory
        echo 0 >$llccbw/bw_hwmon/hyst_length
        echo 80 >$llccbw/bw_hwmon/down_thres
        echo 0 >$llccbw/bw_hwmon/guard_band_mbps
        echo 250 >$llccbw/bw_hwmon/up_scale
        echo 1600 >$llccbw/bw_hwmon/idle_mbps
      done

      for npubw in $device/*npu-npu-ddr-bw/devfreq/*npu-npu-ddr-bw; do
        echo 1 >/sys/devices/virtual/npu/msm_npu/pwr
        echo "bw_hwmon" >$npubw/governor
        echo 40 >$npubw/polling_interval
        echo "1144 1720 2086 2929 3879 5931 6881" >$npubw/bw_hwmon/mbps_zones
        echo 4 >$npubw/bw_hwmon/sample_ms
        echo 80 >$npubw/bw_hwmon/io_percent
        echo 20 >$npubw/bw_hwmon/hist_memory
        echo 10 >$npubw/bw_hwmon/hyst_length
        echo 30 >$npubw/bw_hwmon/down_thres
        echo 0 >$npubw/bw_hwmon/guard_band_mbps
        echo 250 >$npubw/bw_hwmon/up_scale
        echo 0 >$npubw/bw_hwmon/idle_mbps
        echo 0 >/sys/devices/virtual/npu/msm_npu/pwr
      done

      #Enable mem_latency governor for L3, LLCC, and DDR scaling
      for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat; do
        echo "mem_latency" >$memlat/governor
        echo 10 >$memlat/polling_interval
        echo 400 >$memlat/mem_latency/ratio_ceil
      done

      #Gold L3 ratio ceil
      echo 4000 >/sys/class/devfreq/soc:qcom,cpu6-cpu-l3-lat/mem_latency/ratio_ceil

      #Enable cdspl3 governor for L3 cdsp nodes
      for l3cdsp in $device/*cdsp-cdsp-l3-lat/devfreq/*cdsp-cdsp-l3-lat; do
        echo "cdspl3" >$l3cdsp/governor
      done

      #Enable compute governor for gold latfloor
      for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*; do
        echo "compute" >$latfloor/governor
        echo 10 >$latfloor/polling_interval
      done

    done

    # cpuset parameters
    echo 0-5 >/dev/cpuset/background/cpus
    echo 0-5 >/dev/cpuset/system-background/cpus

    # Turn off scheduler boost at the end
    echo 0 >/proc/sys/kernel/sched_boost

    # Turn on sleep modes.
    echo 0 >/sys/module/lpm_levels/parameters/sleep_disabled
    ;;
  esac
}

function sdm710_configuration() {
    # Initial configurations for SDM710 need testing
    # Maybe in the future i can do a proper configuration for performance for THIS
    # SoC

    #Enable bus-dcvs
    # Use bw_hwmon to avoid janks
    echo "bw_hwmon" > /sys/class/devfreq/soc:qcom,cpubw/governor
    echo 50 > /sys/class/devfreq/soc:qcom,cpubw/polling_interval
    echo "1144 1720 2086 2929 3879 5931 6881" > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/mbps_zones
    echo 4 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/sample_ms
    echo 68 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/io_percent
    echo 20 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/hist_memory
    echo 10 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/hyst_length
    echo 80 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/down_thres
    echo 0 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/guard_band_mbps
    echo 250 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/up_scale
    echo 1600 > /sys/class/devfreq/soc:qcom,cpubw/bw_hwmon/idle_mbps
    echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor

    #Optimize memory latency
    echo "mem_latency" > /sys/class/devfreq/soc:qcom,memlat-cpu0/governor
    echo 11 > /sys/class/devfreq/soc:qcom,memlat-cpu0/polling_interval
    echo 400 > /sys/class/devfreq/soc:qcom,memlat-cpu0/mem_latency/ratio_ceil
    echo "mem_latency" > /sys/class/devfreq/soc:qcom,memlat-cpu6/governor
    echo 11 > /sys/class/devfreq/soc:qcom,memlat-cpu6/polling_interval
    echo 400 > /sys/class/devfreq/soc:qcom,memlat-cpu6/mem_latency/ratio_ceil

    #Enable mem_latency governor for L3 scaling
    echo "mem_latency" > /sys/class/devfreq/soc:qcom,l3-cpu0/governor
    echo 11 > /sys/class/devfreq/soc:qcom,l3-cpu0/polling_interval
    echo 400 > /sys/class/devfreq/soc:qcom,l3-cpu0/mem_latency/ratio_ceil
    echo "mem_latency" > /sys/class/devfreq/soc:qcom,l3-cpu6/governor
    echo 11 > /sys/class/devfreq/soc:qcom,l3-cpu6/polling_interval
    echo 400 > /sys/class/devfreq/soc:qcom,l3-cpu6/mem_latency/ratio_ceil

    # Limit the min frequency of LC to 576MHz
    echo 576000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    # Limit the min frequency of BC to 825MHz
    echo 825600 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

    # Change l3-cdsp to userspace governor
    echo "userspace" > /sys/class/devfreq/soc:qcom,l3-cdsp/governor
    chown -h system system /sys/class/devfreq/soc:qcom,l3-cdsp/userspace/set_freq

    # Disable CPU Retention
    echo N > /sys/module/lpm_levels/L3/cpu0/ret/idle_enabled
    echo N > /sys/module/lpm_levels/L3/cpu1/ret/idle_enabled
    echo N > /sys/module/lpm_levels/L3/cpu2/ret/idle_enabled
    echo N > /sys/module/lpm_levels/L3/cpu3/ret/idle_enabled
    echo N > /sys/module/lpm_levels/L3/cpu4/ret/idle_enabled
    echo N > /sys/module/lpm_levels/L3/cpu5/ret/idle_enabled
    echo N > /sys/module/lpm_levels/L3/cpu6/ret/idle_enabled
    echo N > /sys/module/lpm_levels/L3/cpu7/ret/idle_enabled

    # Optimize SchedUtil for little cluster
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 500 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us

    # Optimize SchedUtil for Big cluster
    echo "schedutil" > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
    echo 500 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/up_rate_limit_us
    echo 20000 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/down_rate_limit_us

    # b/37682684 Enable suspend clock reporting
    echo 1 > /sys/kernel/debug/clk/debug_suspend

    # set default schedTune value for foreground/top-app
    echo 1 > /dev/stune/foreground/schedtune.prefer_idle
    echo 10 >  /dev/stune/top-app/schedtune.boost
    echo 1 > /dev/stune/top-app/schedtune.prefer_idle

}

# copy GPU frequencies to vendor property
if [ -f /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies ]; then
  gpu_freq=$(cat /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies) 2>/dev/null
  setprop vendor.gpu.available_frequencies "$gpu_freq"
fi

########################################################################################
##########                Finish CPU configuration                       ###############
########################################################################################
target=$(getprop ro.board.platform)
device=$(getprop ro.xpe.model)
gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

function configure_zram_parameters() {
  MemTotalStr=$(cat /proc/meminfo | grep MemTotal)
  MemTotal=${MemTotalStr:16:8}

  low_ram=$(getprop ro.config.low_ram)

  # Zram disk - 75% for Go devices.
  # For 512MB Go device, size = 384MB, set same for Non-Go.
  # For 1GB Go device, size = 768MB, set same for Non-Go.
  # For >1GB and <=3GB Non-Go device, size = 1GB
  # For >3GB and <=4GB Non-Go device, size = 2GB
  # For >4GB Non-Go device, size = 4GB
  # And enable lz4 zram compression for Go targets.
  # to make it more easy for all we can use this code extracted from CAF
  # Copyright (c) 2012-2013, 2016-2018, The Linux Foundation. All rights reserved.

  RamSizeGB=$(echo "($MemTotal / 1048576 ) + 1" | bc)
  zRamSizeBytes=$(echo "$RamSizeGB * 1024 * 1024 * 1024 / 2" | bc)
  zRamSizeMB=$(echo "$RamSizeGB * 1024 / 2" | bc)
  # use MB avoid 32 bit overflow
  if [ $zRamSizeMB -gt 4096 ]; then
    zRamSizeBytes=4294967296
  fi

  if [ "$low_ram" == "true" ]; then
    echo lz4 >/sys/block/zram0/comp_algorithm
  fi

  if [ -f /sys/block/zram0/disksize ]; then
    if [ -f /sys/block/zram0/use_dedup ]; then
      echo 1 >/sys/block/zram0/use_dedup
    fi
    if [ $MemTotal -le 524288 ]; then
      echo 402653184 >/sys/block/zram0/disksize
    elif [ $MemTotal -le 1048576 ]; then
      echo 805306368 >/sys/block/zram0/disksize
    else
      echo $zRamSizeBytes >/sys/block/zram0/disksize
    fi

    # ZRAM may use more memory than it saves if SLAB_STORE_USER
    # debug option is enabled.
    if [ -e /sys/kernel/slab/zs_handle ]; then
      echo 0 >/sys/kernel/slab/zs_handle/store_user
    fi
    if [ -e /sys/kernel/slab/zspage ]; then
      echo 0 >/sys/kernel/slab/zspage/store_user
    fi

    mkswap /dev/block/zram0
    swapon /dev/block/zram0 -p 32758
  fi
}

function configure_read_ahead_kb_values() {
  MemTotalStr=$(cat /proc/meminfo | grep MemTotal)
  MemTotal=${MemTotalStr:16:8}

  dmpts=$(ls /sys/block/*/queue/read_ahead_kb | grep -e dm -e mmc)

  # Set 128 for <= 3GB &
  # set 512 for >= 4GB targets.
  if [ $MemTotal -le 3145728 ]; then
    echo 128 >/sys/block/mmcblk0/bdi/read_ahead_kb
    echo 128 >/sys/block/mmcblk0rpmb/bdi/read_ahead_kb
    for dm in $dmpts; do
      echo 128 >$dm
    done
  else
    echo 512 >/sys/block/mmcblk0/bdi/read_ahead_kb
    echo 512 >/sys/block/mmcblk0rpmb/bdi/read_ahead_kb
    for dm in $dmpts; do
      echo 512 >$dm
    done
  fi
}

function disable_core_ctl() {
  if [ -f /sys/devices/system/cpu/cpu0/core_ctl/enable ]; then
    echo 0 >/sys/devices/system/cpu/cpu0/core_ctl/enable
  else
    echo 1 >/sys/devices/system/cpu/cpu0/core_ctl/disable
  fi
}

function configure_memory_parameters() {
  # Set Memory parameters.
  #
  # Set per_process_reclaim tuning parameters
  # All targets will use vmpressure range 50-70,
  # All targets will use 512 pages swap size.
  #
  # Set Low memory killer minfree parameters
  # 32 bit Non-Go, all memory configurations will use 15K series
  # 32 bit Go, all memory configurations will use uLMK + Memcg
  # 64 bit will use Google default LMK series.
  #
  # Set ALMK parameters (usually above the highest minfree values)
  # vmpressure_file_min threshold is always set slightly higher
  # than LMK minfree's last bin value for all targets. It is calculated as
  # vmpressure_file_min = (last bin - second last bin ) + last bin
  #
  # Set allocstall_threshold to 0 for all targets.
  #

  ProductName=$(getprop ro.board.platform)
  low_ram=$(getprop ro.config.low_ram)

  if [ "$ProductName" == "msmnile" ] || [ "$ProductName" == "kona" ] || [ "$ProductName" == "sdmshrike_au" ]; then
    # Enable ZRAM
    configure_zram_parameters
    configure_read_ahead_kb_values
    echo 0 >/proc/sys/vm/page-cluster
    echo 100 >/proc/sys/vm/swappiness
  else
    arch_type=$(uname -m)
    MemTotalStr=$(cat /proc/meminfo | grep MemTotal)
    MemTotal=${MemTotalStr:16:8}

    # Set parameters for 32-bit Go targets.
    if [ $MemTotal -le 1048576 ] && [ "$low_ram" == "true" ]; then
      # Disable KLMK, ALMK, PPR & Core Control for Go devices
      echo 0 >/sys/module/lowmemorykiller/parameters/enable_lmk
      echo 0 >/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
      echo 0 >/sys/module/process_reclaim/parameters/enable_process_reclaim
      disable_core_ctl
      # Enable oom_reaper for Go devices
      if [ -f /proc/sys/vm/reap_mem_on_sigkill ]; then
        echo 1 >/proc/sys/vm/reap_mem_on_sigkill
      fi
    else

      # Read adj series and set adj threshold for PPR and ALMK.
      # This is required since adj values change from framework to framework.
      adj_series=$(cat /sys/module/lowmemorykiller/parameters/adj)
      adj_1="${adj_series#*,}"
      set_almk_ppr_adj="${adj_1%%,*}"

      # PPR and ALMK should not act on HOME adj and below.
      # Normalized ADJ for HOME is 6. Hence multiply by 6
      # ADJ score represented as INT in LMK params, actual score can be in decimal
      # Hence add 6 considering a worst case of 0.9 conversion to INT (0.9*6).
      # For uLMK + Memcg, this will be set as 6 since adj is zero.
      set_almk_ppr_adj=$(((set_almk_ppr_adj * 6) + 6))
      echo $set_almk_ppr_adj >/sys/module/lowmemorykiller/parameters/adj_max_shift

      # Calculate vmpressure_file_min as below & set for 64 bit:
      # vmpressure_file_min = last_lmk_bin + (last_lmk_bin - last_but_one_lmk_bin)
      if [ "$arch_type" == "aarch64" ]; then
        minfree_series=$(cat /sys/module/lowmemorykiller/parameters/minfree)
        minfree_1="${minfree_series#*,}"
        rem_minfree_1="${minfree_1%%,*}"
        minfree_2="${minfree_1#*,}"
        rem_minfree_2="${minfree_2%%,*}"
        minfree_3="${minfree_2#*,}"
        rem_minfree_3="${minfree_3%%,*}"
        minfree_4="${minfree_3#*,}"
        rem_minfree_4="${minfree_4%%,*}"
        minfree_5="${minfree_4#*,}"

        vmpres_file_min=$((minfree_5 + (minfree_5 - rem_minfree_4)))
        echo $vmpres_file_min >/sys/module/lowmemorykiller/parameters/vmpressure_file_min
      else
        # Set LMK series, vmpressure_file_min for 32 bit non-go targets.
        # Disable Core Control, enable KLMK for non-go 8909.
        if [ "$ProductName" == "msm8909" ]; then
          disable_core_ctl
          echo 1 >/sys/module/lowmemorykiller/parameters/enable_lmk
        fi
        echo "15360,19200,23040,26880,34415,43737" >/sys/module/lowmemorykiller/parameters/minfree
        echo 53059 >/sys/module/lowmemorykiller/parameters/vmpressure_file_min
      fi

      # Enable adaptive LMK for all targets &
      # use Google default LMK series for all 64-bit targets >=2GB.
      echo 1 >/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk

      # Enable oom_reaper
      if [ -f /sys/module/lowmemorykiller/parameters/oom_reaper ]; then
        echo 1 >/sys/module/lowmemorykiller/parameters/oom_reaper
      fi

      # Set PPR parameters
      if [ -f /sys/devices/soc0/soc_id ]; then
        soc_id=$(cat /sys/devices/soc0/soc_id)
      else
        soc_id=$(cat /sys/devices/system/soc/soc0/id)
      fi

      case "$soc_id" in
      # Do not set PPR parameters for premium targets
      # sdm845 - 321, 341
      # msm8998 - 292, 319
      # msm8996 - 246, 291, 305, 312
      "321" | "341" | "292" | "319" | "246" | "291" | "305" | "312") ;;

      *)
        #Set PPR parameters for all other targets.
        echo $set_almk_ppr_adj >/sys/module/process_reclaim/parameters/min_score_adj
        echo 1 >/sys/module/process_reclaim/parameters/enable_process_reclaim
        echo 50 >/sys/module/process_reclaim/parameters/pressure_min
        echo 70 >/sys/module/process_reclaim/parameters/pressure_max
        echo 30 >/sys/module/process_reclaim/parameters/swap_opt_eff
        echo 512 >/sys/module/process_reclaim/parameters/per_swap_size
        ;;
      esac
    fi

    # Set allocstall_threshold to 0 for all targets.
    # Set swappiness to 100 for all targets
    echo 0 >/sys/module/vmpressure/parameters/allocstall_threshold
    echo 100 >/proc/sys/vm/swappiness

    # Disable wsf for all targets beacause we are using efk.
    # wsf Range : 1..1000 So set to bare minimum value 1.
    echo 1 >/proc/sys/vm/watermark_scale_factor

    configure_zram_parameters

    configure_read_ahead_kb_values

    enable_swap
  fi
}

function enable_memory_features() {
  MemTotalStr=$(cat /proc/meminfo | grep MemTotal)
  MemTotal=${MemTotalStr:16:8}
  if [ $MemTotal -le 2097152 ]; then
    #Enable B service adj transition for 2GB or less memory
    setprop ro.vendor.qti.sys.fw.bservice_enable true
    setprop ro.vendor.qti.sys.fw.bservice_limit 5
    setprop ro.vendor.qti.sys.fw.bservice_age 5000
    #Enable Delay Service Restart
    setprop ro.vendor.qti.am.reschedule_service true
  fi

  # Enable adaptive LMK for all targets &
  # use Google default LMK series for all 64-bit targets >=2GB.
  echo 1>sys/module/lowmemorykiller/parameters/enable_adaptive_lmk

}

#swap only for 1GB devices
function enable_swap() {
  MemTotalStr=$(cat /proc/meminfo | grep MemTotal)
  MemTotal=${MemTotalStr:16:8}

  SWAP_ENABLE_THRESHOLD=1048576
  swap_enable=$(getprop ro.vendor.xperience.config.swap)

  # Enable swap initially only for 1 GB targets
  if [ "$MemTotal" -le "$SWAP_ENABLE_THRESHOLD" ] && [ "$swap_enable" == "true" ]; then
    # Static swiftness
    echo 1 >/proc/sys/vm/swap_ratio_enable
    echo 70 >/proc/sys/vm/swap_ratio

    # Swap disk - 200MB size
    if [ ! -f /data/vendor/swap/swapfile ]; then
      dd if=/dev/zero of=/data/vendor/swap/swapfile bs=1m count=200
    fi
    mkswap /data/vendor/swap/swapfile
    swapon /data/vendor/swap/swapfile -p 32758
  fi
}

# Check panel_name
panel_model=$(cat /sys/class/graphics/fb0/msm_fb_panel_info | grep panel_name)
#default_color=`getprop vendor.display.enable_default_color_mode`

function buning_tianma_fix() {
  # mainly on mido devices
  if [ "$panel_model" == "panel_name=nt35596 tianma fhd video mode dsi panel" ]; then

    #    if [ "$default_color" == "1" ]; then
    #	    setprop vendor.display.enable_default_color_mode 0
    #	fi

    echo "1" >/sys/devices/platform/kcal_ctrl.0/kcal_enable
    echo "237 237 237" >/sys/devices/platform/kcal_ctrl.0/kcal
    echo "258" >/sys/devices/platform/kcal_ctrl.0/kcal_sat
    setprop vendor.xperience.post_boot.color_calibration panel_nt35596
  fi

  # Mainly on vince
  if [ "$panel_model" == "panel_name=td4310 fhdplus e7 video mode dsi panel" ]; then

    #    if [ "$default_color" == "1" ]; then
    #	    setprop vendor.display.enable_default_color_mode 0
    #	fi

    echo "1" >sys/devices/platform/kcal_ctrl.0/kcal_enable
    echo "237 237 237" >sys/devices/platform/kcal_ctrl.0/kcal
    echo "258" >sys/devices/platform/kcal_ctrl.0/kcal_sat
    setprop vendor.xperience.post_boot.color_calibration panel_td4310
  fi

  # Lavender Tianma
  if [ "$panel_model" == "panel_name=tianma nt36672a fhdplus video mode dsi panel" ]; then
    echo "1" >/sys/devices/platform/kcal_ctrl.0/kcal_enable
    echo "237 237 237" >/sys/devices/platform/kcal_ctrl.0/kcal
    setprop vendor.xperience.post_boot.color_calibration panel_nt35596
  fi

}

function fixTethering() {
  ln -sf /system/vendor/etc/hostapd/hostapd.conf /data/vendor/wifi/hostapd/hostapd.conf
}

#some devices have issues doing the copy of the hostapd.conf file so fix them
fixTethering

# call tianma burning fix
buning_tianma_fix

#configure memory parameters
configure_memory_parameters

case "$target" in
"msm8226")
  msm8226_config
  configure_zram_parameters
  enable_memory_features
  configure_read_ahead_kb_values
  setprop vendor.xperience.post_boot.parsed 8226
  setprop ro.vendor.xperience.config.swap true
  enable_swap
  ;;
esac

case "$target" in
"msm8917")
  #execute his EAS configuration
  if [ "$gov" = "schedutil" -o "$gov" = "schedalessa" ]; then
    8917_sched_eas_config
    setprop vendor.xperience.post_boot.conf EAS
  else
    8917_sched_dcvs_hmp
    setprop vendor.xperience.post_boot.conf HMP
  fi
  #configure memory features
  enable_memory_features
  configure_zram_parameters
  configure_read_ahead_kb_values
  #to know if this was executed
  setprop vendor.xperience.post_boot.parsed 8917
  ;;
esac

case "$target" in
"msm8937")
  #execute his EAS configuration
  if [ "$gov" = "schedutil" -o "$gov" = "schedalessa" ]; then
    8937_sched_eas_config
    setprop vendor.xperience.post_boot.conf EAS
  else
    8937_sched_dcvs_hmp
    setprop vendor.xperience.post_boot.conf HMP
  fi
  #configure memory features
  enable_memory_features
  configure_zram_parameters
  configure_read_ahead_kb_values
  #to know if this was executed
  setprop vendor.xperience.post_boot.parsed 8937
  ;;
esac
case "$target" in
"msm8953")
  #execute his EAS configuration
  if [ "$gov" = "schedutil" -o "$gov" = "schedalessa" ]; then
    8953_sched_eas_config
    setprop vendor.xperience.post_boot.conf EAS
  else
    8953_sched_dcvs_hmp
    setprop vendor.xperience.post_boot.conf HMP
  fi
  #configure memory features
  enable_memory_features
  configure_zram_parameters
  configure_read_ahead_kb_values
  #to know if this was executed
  setprop vendor.xperience.post_boot.parsed 8953
  ;;
esac

case "$target" in
"sdm660")
  if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=$(cat /sys/devices/soc0/soc_id)
  else
    soc_id=$(cat /sys/devices/system/soc/soc0/id)
  fi
  #Apply settings for sdm660, sdm636,sda636
  case "$soc_id" in
  "317" | "324" | "325" | "326" | "345" | "346")
    #execute his EAS configuration
    sdm660_configuration() enable_memory_features #configure memory features
    configure_zram_parameters
    configure_read_ahead_kb_values
    #to know if this was executed
    setprop vendor.xperience.post_boot.parsed sdm660
    setprop vendor.xperience.post_boot.soc_id $soc_id
    ;;
  esac
  ;;
esac

case "$target" in
"sm6150")
  if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=$(cat /sys/devices/soc0/soc_id)
  else
    soc_id=$(cat /sys/devices/system/soc/soc0/id)
  fi
  case "$soc_id" in
  "355" | "369" | "377" | "380" | "384")
    #Execute configurations
    sm6150_configuration
    enable_memory_features
    configure_zram_parameters
    configure_read_ahead_kb_values
    #to know if this was executed
    setprop vendor.xperience.post_boot.parsed sm6150
    setprop vendor.xperience.post_boot.soc_id $soc_id
    ;;
  esac
  ;;
esac

case "$target" in
    "sdm710")
     sdm710_configuration
     enable_memory_features
     configure_zram_parameters
     configure_read_ahead_kb_values
     setprop vendor.xperience.post_boot.parsed sdm710
     ;;
   esac

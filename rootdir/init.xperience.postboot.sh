#! /vendor/bin/sh

# Copyright  2018-2019 The XPerience Project
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
      echo 1> sys/devices/system/cpu/cpu0/online
      echo "schedalessa"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0> sys/devices/system/cpu/cpufreq/schedalessa/rate_limit_us
      #set the hispeed_freq
      echo 1401600> sys/devices/system/cpu/cpufreq/schedalessa/hispeed_freq
      #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
      echo 85> sys/devices/system/cpu/cpufreq/schedalessa/hispeed_load
    else
      #governor settings
      echo 1> sys/devices/system/cpu/cpu0/online
      echo "schedutil"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0> sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
      #set the hispeed_freq
      echo 1401600> sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
      #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
      echo 85> sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
    fi
  else
    #detect if we have SchedAlessa if not use SchedUtil configuration
    if [ "$gov" = "schedalessa" ]; then
      #governor settings schedalessa
      echo 1> sys/devices/system/cpu/cpu0/online
      echo "schedalessa"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0> sys/devices/system/cpu/cpufreq/schedalessa/up_rate_limit_us
      echo 0> sys/devices/system/cpu/cpufreq/schedalessa/down_rate_limit_us
      #BigCluster
      echo 1> sys/devices/system/cpu/cpu4/online
      echo "schedalessa"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
      echo 0> sys/devices/system/cpu/cpu4/cpufreq/schedutil/rate_limit_us
      echo 1363200> sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
    else
      #governor settings schedutil
      echo 1> sys/devices/system/cpu/cpu0/online
      echo "schedutil"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
      echo 0> sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
      echo 0> sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
      echo 0> sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
      #set the hispeed_freq
      echo 1401600> sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
      #default value for hispeed_load is 90, for 8953 and sdm450 it should be 85
      echo 85> sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
      echo 1> sys/devices/system/cpu/cpu4/online
      echo "schedutil"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
      echo 0> sys/devices/system/cpu/cpu4/cpufreq/schedutil/rate_limit_us
      echo 1401600> sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
    fi
  fi

  setprop vendor.xperience.easkernelversion $KernelVersionA.$KernelVersionB

  #init task load, restrict wakeups to preferred cluster
  echo 15> proc/sys/kernel/sched_init_task_load
  #force set min freq cuz in some weird cases that is set to 1ghz
  echo 652800> sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  # force set max freq due to some random bug where is setting max freq as 1.6ghz
  echo 2016000> sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

  # Bring up all cores online
  echo 1> sys/devices/system/cpu/cpu1/online
  echo 1> sys/devices/system/cpu/cpu2/online
  echo 1> sys/devices/system/cpu/cpu3/online
  echo 1> sys/devices/system/cpu/cpu4/online
  echo 1> sys/devices/system/cpu/cpu5/online
  echo 1> sys/devices/system/cpu/cpu6/online
  echo 1> sys/devices/system/cpu/cpu7/online

  # Enable low power modes
  echo 0> sys/module/lpm_levels/parameters/sleep_disabled

  # choose idle CPU for top app tasks
  echo 1> dev/stune/top-app/schedtune.prefer_idle
  echo 1> dev/stune/top-app/schedtune.sched_boost

  #Enable Schedtune boost
  echo 1> dev/stune/schedtune.boost
}

function 8917_sched_eas_config() {
  #governor settings schedalessa
  echo 1> sys/devices/system/cpu/cpu0/online
  echo "schedutil"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0> sys/devices/system/cpu/cpufreq/schedalessa/up_rate_limit_us
  echo 0> sys/devices/system/cpu/cpufreq/schedalessa/down_rate_limit_us

  #governor settings schedutil
  echo 1> sys/devices/system/cpu/cpu0/online
  echo "schedutil"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0> sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
  #set the hispeed_freq
  echo 1094400> sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
  #default value for hispeed_load is 90, for 8917 it should be 85
  echo 85> sys/devices/system/cpu/cpufreq/schedutil/hispeed_load

}

function 8937_sched_eas_config() {
  # enable governor for perf cluster schedalessa
  echo 1> sys/devices/system/cpu/cpu0/online
  echo "schedalessa"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/schedalessa/up_rate_limit_us
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/schedalessa/down_rate_limit_us
  #configure schedutil too maybe some people wants it :P
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
  #set the hispeed_freq
  echo 1094400> sys/devices/system/cpu/cpu0/cpufreq/schedalessa/hispeed_freq
  #default value for hispeed_load is 90, for 8937 it should be 85
  echo 85> sys/devices/system/cpu/cpu0/cpufreq/schedalessa/hispeed_load
  ## enable governor for power cluster
  echo 1> sys/devices/system/cpu/cpu4/online
  echo "schedutil"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
  echo 0> sys/devices/system/cpu/cpu4/cpufreq/schedalessa/up_rate_limit_us
  echo 0> sys/devices/system/cpu/cpu4/cpufreq/schedalessa/down_rate_limit_us
  #configure schedutil too maybe some people wants it :P
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us

  # enable governor for perf cluster schedutil
  echo 1> sys/devices/system/cpu/cpu0/online
  echo "schedutil"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/schedutil/rate_limit_us
  #set the hispeed_freq
  echo 1094400> sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
  #default value for hispeed_load is 90, for 8937 it should be 85
  echo 85> sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_load
  ## enable governor for power cluster
  echo 1> sys/devices/system/cpu/cpu4/online
  echo "schedutil"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
  echo 0> sys/devices/system/cpu/cpu4/cpufreq/schedutil/rate_limit_us
  #set the hispeed_freq
  echo 768000> sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_freq
  #default value for hispeed_load is 90, for 8937 it should be 85
  echo 85> sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_load

}
############ HMP #######################
function 8953_sched_dcvs_hmp() {
  #scheduler settings
  echo 3> proc/sys/kernel/sched_window_stats_policy
  echo 3> proc/sys/kernel/sched_ravg_hist_size
  #task packing settings
  echo 0> sys/devices/system/cpu/cpu0/sched_static_cpu_pwr_cost
  echo 0> sys/devices/system/cpu/cpu1/sched_static_cpu_pwr_cost
  echo 0> sys/devices/system/cpu/cpu2/sched_static_cpu_pwr_cost
  echo 0> sys/devices/system/cpu/cpu3/sched_static_cpu_pwr_cost
  echo 0> sys/devices/system/cpu/cpu4/sched_static_cpu_pwr_cost
  echo 0> sys/devices/system/cpu/cpu5/sched_static_cpu_pwr_cost
  echo 0> sys/devices/system/cpu/cpu6/sched_static_cpu_pwr_cost
  echo 0> sys/devices/system/cpu/cpu7/sched_static_cpu_pwr_cost
  # spill load is set to 100% by default in the kernel
  echo 3> proc/sys/kernel/sched_spill_nr_run
  # Apply inter-cluster load balancer restrictions
  echo 1> proc/sys/kernel/sched_restrict_cluster_spill
  # set sync wakee policy tunable
  echo 1> proc/sys/kernel/sched_prefer_sync_wakee_to_waker

  #governor settings
  echo 1> sys/devices/system/cpu/cpu0/online
  echo "interactive"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "19000 1401600:39000"> sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
  echo 85> sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
  echo 20000> sys/devices/system/cpu/cpufreq/interactive/timer_rate
  echo 1401600> sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
  echo 0> sys/devices/system/cpu/cpufreq/interactive/io_is_busy
  echo "85 1401600:80"> sys/devices/system/cpu/cpufreq/interactive/target_loads
  echo 39000> sys/devices/system/cpu/cpufreq/interactive/min_sample_time
  echo 40000> sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor
  echo 19> proc/sys/kernel/sched_upmigrate_min_nice
  # Enable sched guided freq control
  echo 1> sys/devices/system/cpu/cpufreq/interactive/use_sched_load
  echo 1> sys/devices/system/cpu/cpufreq/interactive/use_migration_notif
  echo 200000> proc/sys/kernel/sched_freq_inc_notify
  echo 200000> proc/sys/kernel/sched_freq_dec_notify

  # init task load, restrict wakeups to preferred cluster
  echo 15> proc/sys/kernel/sched_init_task_load
}

function 8917_sched_dcvs_hmp() {
  # HMP scheduler settings
  echo 3> proc/sys/kernel/sched_window_stats_policy
  echo 3> proc/sys/kernel/sched_ravg_hist_size
  echo 1> proc/sys/kernel/sched_restrict_tasks_spread
  # HMP Task packing settings
  echo 20> proc/sys/kernel/sched_small_task
  echo 30> sys/devices/system/cpu/cpu0/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu1/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu2/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu3/sched_mostly_idle_load

  echo 3> sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run

  echo 0> sys/devices/system/cpu/cpu0/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu1/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu2/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu3/sched_prefer_idle

  echo 1> sys/devices/system/cpu/cpu0/online
  echo "interactive"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "19000 1094400:39000"> sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
  echo 85> sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
  echo 20000> sys/devices/system/cpu/cpufreq/interactive/timer_rate
  echo 1094400> sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
  echo 0> sys/devices/system/cpu/cpufreq/interactive/io_is_busy
  echo "1 960000:85 1094400:90"> sys/devices/system/cpu/cpufreq/interactive/target_loads
  echo 40000> sys/devices/system/cpu/cpufreq/interactive/min_sample_time
  echo 40000> sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor

  # Enable sched guided freq control
  echo 1> sys/devices/system/cpu/cpufreq/interactive/use_sched_load
  echo 1> sys/devices/system/cpu/cpufreq/interactive/use_migration_notif
  echo 50000> proc/sys/kernel/sched_freq_inc_notify
  echo 50000> proc/sys/kernel/sched_freq_dec_notify
}

function 8937_sched_dcvs_hmp() {
  # HMP scheduler settings
  echo 3> proc/sys/kernel/sched_window_stats_policy
  echo 3> proc/sys/kernel/sched_ravg_hist_size
  # HMP Task packing settings
  echo 20> proc/sys/kernel/sched_small_task
  echo 30> sys/devices/system/cpu/cpu0/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu1/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu2/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu3/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu4/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu5/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu6/sched_mostly_idle_load
  echo 30> sys/devices/system/cpu/cpu7/sched_mostly_idle_load

  echo 3> sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu4/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu5/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu6/sched_mostly_idle_nr_run
  echo 3> sys/devices/system/cpu/cpu7/sched_mostly_idle_nr_run

  echo 0> sys/devices/system/cpu/cpu0/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu1/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu2/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu3/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu4/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu5/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu6/sched_prefer_idle
  echo 0> sys/devices/system/cpu/cpu7/sched_prefer_idle
  # enable governor for perf cluster
  echo 1> sys/devices/system/cpu/cpu0/online
  echo "interactive"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "19000 1094400:39000"> sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
  echo 85> sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
  echo 20000> sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
  echo 1094400> sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
  echo 0> sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
  echo "1 960000:85 1094400:90 1344000:80"> sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
  echo 40000> sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
  echo 40000> sys/devices/system/cpu/cpu0/cpufreq/interactive/sampling_down_factor

  # enable governor for power cluster
  echo 1> sys/devices/system/cpu/cpu4/online
  echo "interactive"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
  echo 39000> sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
  echo 90> sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
  echo 20000> sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
  echo 768000> sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
  echo 0> sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
  echo "1 768000:90"> sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
  echo 40000> sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
  echo 40000> sys/devices/system/cpu/cpu4/cpufreq/interactive/sampling_down_factor

  # Enable sched guided freq control
  echo 1> sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
  echo 1> sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
  echo 1> sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
  echo 1> sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
  echo 50000> proc/sys/kernel/sched_freq_inc_notify
  echo 50000> proc/sys/kernel/sched_freq_dec_notify

}

function msm8226_config() {
  echo 4> sys/module/lpm_levels/enable_low_power/l2
  echo 1> sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
  echo 1> sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
  echo 1> sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
  echo 1> sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
  echo 1> sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
  echo 1> sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
  echo 1> sys/module/msm_pm/modes/cpu1/power_collapse/idle_enabled
  echo 1> sys/module/msm_pm/modes/cpu2/power_collapse/idle_enabled
  echo 1> sys/module/msm_pm/modes/cpu3/power_collapse/idle_enabled
  echo 1> sys/devices/system/cpu/cpu1/online
  echo 1> sys/devices/system/cpu/cpu2/online
  echo 1> sys/devices/system/cpu/cpu3/online
  echo 50000> sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
  echo 90> sys/devices/system/cpu/cpufreq/ondemand/up_threshold
  echo 1> sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
  echo 2> sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
  echo 10> sys/devices/system/cpu/cpufreq/ondemand/down_differential
  echo 70> sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
  echo 10> sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
  echo 787200> sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
  echo 300000> sys/devices/system/cpu/cpufreq/ondemand/sync_freq
  echo 80> sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
  chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
  chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  chown -h root.system /sys/devices/system/cpu/cpu1/online
  chown -h root.system /sys/devices/system/cpu/cpu2/online
  chown -h root.system /sys/devices/system/cpu/cpu3/online
  chmod -h 664 /sys/devices/system/cpu/cpu1/online
  chmod -h 664 /sys/devices/system/cpu/cpu2/online
  chmod -h 664 /sys/devices/system/cpu/cpu3/online
  #Configure intelimm by default to avoid lags

  echo 1190400 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
  echo 1190400 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
  echo 192000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  echo "intellidemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#  start mpdecision
  #enable doubletap2wake
  echo 1 > /sys/android_touch/doubletap2wake
  # force zram on lz4
  echo lz4 > /sys/block/zram0/comp_algorithm

}

function sdm660_configuration() {

  #execute his EAS configuration
  if [ "$gov" = "schedutil" -o "$gov" = "schedalessa" ]; then
    # configure governor settings for little cluster
    echo 1> sys/devices/system/cpu/cpu0/online
    echo "schedutil"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 633600> sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    # configure governor settings for big cluster
    echo 1> sys/devices/system/cpu/cpu4/online
    echo "schedalessa"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 1113600> sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    #extra configs for SchedAlessa and SchedUtil
    echo 500> sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 20000> sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    echo 500> sys/devices/system/cpu/cpu0/cpufreq/schedalessa/up_rate_limit_us
    echo 20000> sys/devices/system/cpu/cpu0/cpufreq/schedalessa/down_rate_limit_us
    echo 500> sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us
    echo 20000> sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us
    echo 500> sys/devices/system/cpu/cpu4/cpufreq/schedalessa/up_rate_limit_us
    echo 20000> sys/devices/system/cpu/cpu4/cpufreq/schedalessa/down_rate_limit_us

    echo 1> proc/sys/kernel/sched_walt_rotate_big_tasks
  else
    # configure governor settings for little cluster
    echo 1> sys/devices/system/cpu/cpu0/online
    echo "schedutil"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 633600> sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    # configure governor settings for big cluster
    echo 1> sys/devices/system/cpu/cpu4/online
    echo "schedutil"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 1113600> sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

    #extra configs for SchedAlessa and SchedUtil
    echo 500> sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
    echo 20000> sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us
    echo 500> sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us
    echo 20000> sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us
    echo 1> proc/sys/kernel/sched_walt_rotate_big_tasks

  fi

  if [ "$gov" = "interactive" ]; then
    # online CPU0
    echo 1> sys/devices/system/cpu/cpu0/online
    # configure governor settings for little cluster
    echo "interactive"> sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 1> sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
    echo 1> sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
    echo "19000 1401600:39000"> sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
    echo 90> sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
    echo 20000> sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
    echo 1401600> sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
    echo 0> sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
    echo "85 1747200:95"> sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
    echo 39000> sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
    echo 0> sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
    echo 633600> sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1> sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif
    echo 1> sys/devices/system/cpu/cpu0/cpufreq/interactive/fast_ramp_down

    # online CPU4
    echo 1> sys/devices/system/cpu/cpu4/online
    # configure governor settings for big cluster
    echo "interactive"> sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 1> sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
    echo 1> sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
    echo "19000 1401600:39000"> sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
    echo 90> sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
    echo 20000> sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
    echo 1401600> sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
    echo 0> sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
    echo "85 1401600:90 2150400:95"> sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
    echo 39000> sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
    echo 59000> sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
    echo 1113600> sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
    echo 1> sys/devices/system/cpu/cpu4/cpufreq/interactive/ignore_hispeed_on_notif
    echo 1> sys/devices/system/cpu/cpu4/cpufreq/interactive/fast_ramp_down

  fi

  echo 2> sys/devices/system/cpu/cpu4/core_ctl/min_cpus
  echo 60> sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
  echo 30> sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
  echo 100> sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
  echo 1> sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
  echo 4> sys/devices/system/cpu/cpu4/core_ctl/task_thres

  # Setting b.L scheduler parameters
  echo 96> proc/sys/kernel/sched_upmigrate
  echo 90> proc/sys/kernel/sched_downmigrate
  echo 140> proc/sys/kernel/sched_group_upmigrate
  echo 120> proc/sys/kernel/sched_group_downmigrate
  echo 0> proc/sys/kernel/sched_select_prev_cpu_us
  echo 400000> proc/sys/kernel/sched_freq_inc_notify
  echo 400000> proc/sys/kernel/sched_freq_dec_notify
  echo 5> proc/sys/kernel/sched_spill_nr_run
  echo 1> proc/sys/kernel/sched_restrict_cluster_spill
  echo 100000> proc/sys/kernel/sched_short_burst_ns
  echo 1> proc/sys/kernel/sched_prefer_sync_wakee_to_waker
  echo 20> proc/sys/kernel/sched_small_wakee_task_load

    # cpuset settings
    echo 0-1 > /dev/cpuset/background/cpus
    echo 0-2 > /dev/cpuset/system-background/cpus
    echo 0-3 > /dev/cpuset/restricted/cpus

            # Enable bus-dcvs
            for cpubw in /sys/class/devfreq/*qcom,cpubw*
            do
                echo "bw_hwmon" > $cpubw/governor
                echo 50 > $cpubw/polling_interval
                echo 762 > $cpubw/min_freq
                echo "1525 3143 5859 7759 9887 10327 11863 13763" > $cpubw/bw_hwmon/mbps_zones
                echo 4 > $cpubw/bw_hwmon/sample_ms
                echo 85 > $cpubw/bw_hwmon/io_percent
                echo 100 > $cpubw/bw_hwmon/decay_rate
                echo 50 > $cpubw/bw_hwmon/bw_step
                echo 20 > $cpubw/bw_hwmon/hist_memory
                echo 0 > $cpubw/bw_hwmon/hyst_length
                echo 80 > $cpubw/bw_hwmon/down_thres
                echo 0 > $cpubw/bw_hwmon/low_power_ceil_mbps
                echo 34 > $cpubw/bw_hwmon/low_power_io_percent
                echo 20 > $cpubw/bw_hwmon/low_power_delay
                echo 0 > $cpubw/bw_hwmon/guard_band_mbps
                echo 250 > $cpubw/bw_hwmon/up_scale
                echo 1600 > $cpubw/bw_hwmon/idle_mbps
            done

            for memlat in /sys/class/devfreq/*qcom,memlat-cpu*
            do
                echo "mem_latency" > $memlat/governor
                echo 10 > $memlat/polling_interval
                echo 400 > $memlat/mem_latency/ratio_ceil
            done
            echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor

}

####SDM 660 ###

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

    RamSizeGB=`echo "($MemTotal / 1048576 ) + 1" | bc`
    zRamSizeBytes=`echo "$RamSizeGB * 1024 * 1024 * 1024 / 2" | bc`
    zRamSizeMB=`echo "$RamSizeGB * 1024 / 2" | bc`
    # use MB avoid 32 bit overflow
    if [ $zRamSizeMB -gt 4096 ]; then
        zRamSizeBytes=4294967296
    fi

    if [ "$low_ram" == "true" ]; then
        echo lz4 > /sys/block/zram0/comp_algorithm
    fi

    if [ -f /sys/block/zram0/disksize ]; then
        if [ -f /sys/block/zram0/use_dedup ]; then
            echo 1 > /sys/block/zram0/use_dedup
        fi
        if [ $MemTotal -le 524288 ]; then
            echo 402653184 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 1048576 ]; then
            echo 805306368 > /sys/block/zram0/disksize
        else
            echo $zRamSizeBytes > /sys/block/zram0/disksize
        fi

        # ZRAM may use more memory than it saves if SLAB_STORE_USER
        # debug option is enabled.
        if [ -e /sys/kernel/slab/zs_handle ]; then
            echo 0 > /sys/kernel/slab/zs_handle/store_user
        fi
        if [ -e /sys/kernel/slab/zspage ]; then
            echo 0 > /sys/kernel/slab/zspage/store_user
        fi

        mkswap /dev/block/zram0
        swapon /dev/block/zram0 -p 32758
    fi
}

function configure_read_ahead_kb_values() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    dmpts=$(ls /sys/block/*/queue/read_ahead_kb | grep -e dm -e mmc)

    # Set 128 for <= 3GB &
    # set 512 for >= 4GB targets.
    if [ $MemTotal -le 3145728 ]; then
        echo 128 > /sys/block/mmcblk0/bdi/read_ahead_kb
        echo 128 > /sys/block/mmcblk0rpmb/bdi/read_ahead_kb
        for dm in $dmpts; do
            echo 128 > $dm
        done
    else
        echo 512 > /sys/block/mmcblk0/bdi/read_ahead_kb
        echo 512 > /sys/block/mmcblk0rpmb/bdi/read_ahead_kb
        for dm in $dmpts; do
            echo 512 > $dm
        done
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
  echo 1> sys/module/lowmemorykiller/parameters/enable_adaptive_lmk

}

#swap only for 1GB devices
function enable_swap() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    SWAP_ENABLE_THRESHOLD=1048576
    swap_enable=`getprop ro.vendor.xperience.config.swap`

    # Enable swap initially only for 1 GB targets
    if [ "$MemTotal" -le "$SWAP_ENABLE_THRESHOLD" ] && [ "$swap_enable" == "true" ]; then
        # Static swiftness
        echo 1 > /proc/sys/vm/swap_ratio_enable
        echo 70 > /proc/sys/vm/swap_ratio

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

    echo "1" > /sys/devices/platform/kcal_ctrl.0/kcal_enable
    echo "237 237 237" > /sys/devices/platform/kcal_ctrl.0/kcal
    echo "258" > /sys/devices/platform/kcal_ctrl.0/kcal_sat
    setprop vendor.xperience.post_boot.color_calibration panel_nt35596
  fi

  # Mainly on vince
  if [ "$panel_model" == "panel_name=td4310 fhdplus e7 video mode dsi panel" ]; then

    #    if [ "$default_color" == "1" ]; then
    #	    setprop vendor.display.enable_default_color_mode 0
    #	fi

    echo "1"> sys/devices/platform/kcal_ctrl.0/kcal_enable
    echo "237 237 237"> sys/devices/platform/kcal_ctrl.0/kcal
    echo "258"> sys/devices/platform/kcal_ctrl.0/kcal_sat
    setprop vendor.xperience.post_boot.color_calibration panel_td4310
  fi

  # Lavender Tianma
  if [ "$panel_model" == "panel_name=tianma nt36672a fhdplus video mode dsi panel" ]; then
    echo "1" > /sys/devices/platform/kcal_ctrl.0/kcal_enable
    echo "237 237 237" > /sys/devices/platform/kcal_ctrl.0/kcal
    setprop vendor.xperience.post_boot.color_calibration panel_nt35596
  fi

}

function fixTethering(){
  ln -sf /system/vendor/etc/hostapd/hostapd.conf /data/vendor/wifi/hostapd/hostapd.conf
}

#some devices have issues doing the copy of the hostapd.conf file so fix them
fixTethering

# call tianma burning fix
buning_tianma_fix

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

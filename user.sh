#!/bin/bash

source ./common.sh
APP_NAME="catalogue"

check_root
app_user_setup
app_setup
nodejs_install

systemd_setup

print_tot_time


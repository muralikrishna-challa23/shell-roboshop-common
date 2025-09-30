#!/bin/bash

APP_NAME="cart"
source ./common.sh

check_root

nodejs_setup

app_user_setup

app_setup

systemd_setup

print_tot_time
#!/bin/bash

APP_NAME="cart"
source ./common.sh

check_root

app_user_setup

app_setup

nodejs_setup

systemd_setup

print_tot_time
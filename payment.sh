#!/bin/bash

source ./common.sh
APP_NAME="payment"



app_user_setup

app_setup

python_setup

systemd_setup

print_tot_time
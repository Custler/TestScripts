#!/usr/bin/env bash

# (C) Sergey Tyurin  2022-05-16 13:00:00

# Disclaimer
##################################################################################################################
# You running this script/function means you will not blame the author(s)
# if this breaks your stuff. This script/function is provided AS IS without warranty of any kind. 
# Author(s) disclaim all implied warranties including, without limitation, 
# any implied warranties of merchantability or of fitness for a particular purpose. 
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall author(s) be held liable for any damages whatsoever 
# (including, without limitation, damages for loss of business profits, business interruption, 
# loss of business information, or other pecuniary loss) arising out of the use of or inability 
# to use the script or documentation. Neither this script/function, 
# nor any part of it other than those parts that are explicitly copied from others, 
# may be republished without author(s) express written permission. 
# Author(s) retain the right to alter this disclaimer at any time.
##################################################################################################################


echo
echo "##################################### Postupdate Script ########################################"
echo "INFO: $(basename "$0") BEGIN $(date +%s) / $(date  +'%F %T %Z')"

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
source "${SCRIPT_DIR}/env.sh"
source "${SCRIPT_DIR}/functions.shinc"

#################################################################
# DB repair checking
# If DB cannot be repaired - clear DB and start sync from scratch
echo "ATTENTION: Node going to repair DB! If it will unsuccess, the DB will be deleted and resynced.."
"${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME Server" "$Tg_Warn_sign ATTENTION: Node going to repair DB! If it will unsuccess, the DB will be deleted and resynced.." 2>&1 > /dev/null



#===========================================================
# Check if we missed the election due to long update
declare -i CurrTime=$(date +%s)
declare -i election_id=$(Get_Current_Elections_ID)
if [[ $election_id -gt 0 ]];then
    NetConfigP15="$(Get_NetConfig_P15)"
    declare -i EndBefore=$(echo $NetConfigP15|awk '{print $3}')
    if [[ $CurrTime -le $((election_id - EndBefore - 180)) ]];then
        ${SCRIPT_DIR}/prepare_elections.sh && ${SCRIPT_DIR}/take_part_in_elections.sh
        ${SCRIPT_DIR}/next_elect_set_time.sh && ${SCRIPT_DIR}/part_check.sh
    else
        ${SCRIPT_DIR}/next_elect_set_time.sh
    fi
else
    ${SCRIPT_DIR}/next_elect_set_time.sh
fi


# echo "--- nothing to do"
#################################################################

echo "+++INFO: $(basename "$0") FINISHED $(date +%s) / $(date  +'%F %T %Z')"
echo "================================================================================================"

exit 0

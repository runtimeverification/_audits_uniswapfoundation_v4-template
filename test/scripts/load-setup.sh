#!/bin/bash
set -euo pipefail

##########
# WARNING: this script is meant to be run from the foundry root directory
##########

# Execute _setUp with all recording apparatus from SetUp.k.sol
forge test -vvv --mt test_setup2_and_save_addresses

# state-diff/StateDiff.json comes out scaped from the last command
# We execute this script to unscape it so that it can be fed to Kontrol
python3 test/kontrol/scripts/json/clean_json.py state-diff/StateDiff.json

# state-diff/contract-names.json come ordered as "name : address", but we need
# to reverse this for Kontrol to generate the appropriate code
python3 test/kontrol/scripts/json/reverse_key_values.py state-diff/contract-names.json state-diff/contract-names.json

# Finally, we give the appropriate files to Kontrol to create the summary contracts
export SUMMARY_NAME=SetupSummary
export STATEDIFF=StateDiff.json
export CONTRACT_NAMES=state-diff/contract-names.json
export SUMMARY_DIR=test/kontrol/proofs/utils/
export LICENSE=UNLICENSED
kontrol load-state-diff $SUMMARY_NAME state-diff/$STATEDIFF --contract-names $CONTRACT_NAMES --output-dir $SUMMARY_DIR --license $LICENSE
forge fmt $SUMMARY_DIR/$SUMMARY_NAME.sol
forge fmt $SUMMARY_DIR/${SUMMARY_NAME}Code.sol
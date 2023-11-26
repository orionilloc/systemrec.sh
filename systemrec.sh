#!/bin/bash
# This is a script meant for system reconciliation when comparing an external system user list (such as Atlassian, 1Password, Bitwarden, Github, etc) against an IdP user list (such as Okta, OneLogin, Google Workspace, or Active Directory). The first argument should be the IdP user list; the second should be the external system user list. Both need to be in .csv format, or the script will not run.
# The script accepts user-supplied arguments which are declared interally as positional parameters. The script then checks that the file is in a .csv format, before merrily tearing apart the .csv file with some RegEx and sed magic to obtain possibly valid email addresses. It then outputs a list of users to be removed in bulk via an API endpoint.

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
	echo "ERROR: Not enough user arguments provided." && exit 1
elif [[ ! -f "$1" ]] || [[ ! -f "$2" ]]; then 
	echo "ERROR: One or more files do not exist." && exit 2
elif ! file "$1" | grep -q ".csv" || ! file "$2" | grep -q ".csv"; then
	echo "ERROR: One or both files are not valid .csv files." && exit 3 
else
	echo "Please enter the name of the system you are reconciling:" && read -e external_sys
fi

# Uses the comm utility with output from process substitution to find email addresses, then sorting the emails to be used effectively by comm (which will not run correctly unless data is sorted). The sed utility removes any whitespace that happens to remain, and then that output is redirected to a new .csv file.
comm -13 <(grep -i -o '[A-Z0-9._%+-]\+@[A-Z0-9.-]\+\.[A-Z]\{2,4\}' "$1" | sort) <(grep -i -o '[A-Z0-9._%+-]\+@[A-Z0-9.-]\+\.[A-Z]\{2,4\}' "$2" | sort) | sed 's/^[[:space:]]*//g' > ""$external_sys"_users_to_remove.csv"

echo "Results have been outputted to "$external_sys"_users_to_remove.csv"""

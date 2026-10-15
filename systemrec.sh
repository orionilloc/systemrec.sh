#!/usr/bin/env bash
# This is a script meant for basic system reconciliation when comparing an external system user list (such as Atlassian, 1Password, Bitwarden, Github, etc) against an IdP user list (such as Okta, OneLogin, Google Workspace, or Active Directory). The first argument should be the IdP user list; the second should be the external system user list. Both need to be in .csv format, or the script will not run.
# The script accepts user-supplied arguments which are declared internally as positional parameters. The script then checks that the file is in a .csv format, before merrily tearing apart the .csv file with some RegEx magic to obtain possibly valid email addresses. It then outputs a list of users to be removed in bulk via an API endpoint.

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
	printf 'ERROR: Not enough user arguments provided.\n' >&2 && exit 1
elif [[ ! -f "$1" ]] || [[ ! -f "$2" ]]; then
	printf 'ERROR: One or more files do not exist.\n' >&2 && exit 2
elif [[ "$1" != *.csv || "$2" != *.csv ]]; then
	printf 'ERROR: One or both files are not valid .csv files.\n' >&2 && exit 3
else
	read -r -e -p "Enter the name of the system you are reconciling: " external_sys
	if [[ ! "$external_sys" =~ ^[A-Za-z0-9_-]+$ ]]; then
		printf 'ERROR: system name may only contain letters, numbers, - and _.\n' >&2 && exit 4
	fi
fi

# Extracts email addresses with grep, lowercases them (comm compares bytes, so John@x.com and john@x.com would otherwise differ), and sorts them uniquely (comm requires sorted input). The script aborts if the IdP list yields no emails; otherwise comm -13 prints addresses present only in the external system, which are written to a new .csv file.
extract_emails() {
    grep -i -o '[A-Z0-9._%+-]\+@[A-Z0-9.-]\+\.[A-Z]\{2,\}' "$1" | tr '[:upper:]' '[:lower:]' | sort -u
}

idp_emails=$(extract_emails "$1")
if [[ -z "$idp_emails" ]]; then
    printf 'ERROR: no emails found in %s. Aborting.\n' "$1" >&2
    exit 5
fi

ext_emails=$(extract_emails "$2")
comm -13 <(printf '%s\n' "$idp_emails") <(grep . <<< "$ext_emails") > "${external_sys}_users_to_remove.csv"

printf 'IdP emails:      %s\n' "$(grep -c . <<< "$idp_emails")"
printf 'External emails: %s\n' "$(grep -c . <<< "$ext_emails")"
printf 'To remove:       %s\n' "$(wc -l < "${external_sys}_users_to_remove.csv")"
printf 'Results have been written to %s_users_to_remove.csv\n' "$external_sys"

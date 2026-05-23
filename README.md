# systemrec.sh

A Bash script for reconciling user lists between an Identity Provider (IdP) and an external system. Identifies accounts present in the external system but absent from the IdP — the delta representing users pending deprovisioning.

## Features

- **Email Extraction**: Uses regex via `grep` to pull email addresses from both CSVs without relying on column position or header structure.
- **Set Comparison**: Uses `comm` to produce only the emails unique to the external system, suppressing matches and IdP-only entries.
- **Process Substitution**: Avoids temporary files by feeding sorted email lists directly into `comm` via `<(...)`.
- **Input Validation**: Verifies argument count, file existence, and CSV format with explicit exit codes at each check.

## Prerequisites

- **Operating System**: Any Linux system with standard GNU utilities.
- **Utilities**: `grep`, `comm`, `sed`, `file` (pre-installed on most distributions).
- **Input**: Two `.csv` files — IdP user list as the first argument, external system list as the second.

## Usage

```bash
./systemrec.sh <idp_userlist.csv> <external_system_userlist.csv>
```

The script will prompt for the external system name and output a CSV of users to be removed.

## Known Limitations

CSV format detection relies on the `file` utility, which inspects file content rather than extension. Valid CSVs may be identified as `ASCII text` rather than returning a `.csv` string, causing the format check to fail. If the script rejects a valid file, verify with `file your_userlist.csv` and adjust expectations accordingly.

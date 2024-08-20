# Syssec_audit

Syssec_audit is a comprehensive system security audit script designed to help administrators maintain system integrity by performing various checks on files and system settings. It offers functionalities such as detecting hidden files, checking file permissions, listing SUID/SGID files, and more.

## Features

- **Root Check**: Ensures the script runs with root privileges.
  
- **Directory Check**: Creates necessary directories for logging if they don't exist.
  
- **Hidden Files Detection**: Finds files with suspicious names.
  
- **SGID and SUID Files Detection**: Lists files with SGID (Set Group ID) and SUID (Set User ID) permissions.
  
- **MD5 Checksum Calculation**: Computes and verifies MD5 checksums of files.
  
- **File Ownership and Permissions Checks**: Identifies changes in file ownership, permissions, and other attributes.
  
- **World-Writable Files Detection**: Lists files that are world-writable.
  
- **Unowned Files Detection**: Finds files with no owner.
  
- **Email Notifications**: Optionally sends audit results via email.
    
## Usage
    
To run `syssec_audit.sh`, use the following command:
`sudo ./syssec_audit.sh [options]`
    

### Options

- **`-e <email>`**: Send auditing results by email to the specified address.
- **`-f`**: Find and list hidden files.
- **`-g`**: List SGID files.
- **`-h`**: Display help message.
- **`-m`**: List MD5 checksums of files.
- **`-s`**: List SUID files.
- **`-u`**: Find and list unowned files.
- **`-w`**: Find and list world-writable files.

### Example

To run the script and check for hidden files, SUID files, and send the results via email, use:

`sudo ./syssec_audit.sh -f -s -e user@example.com`

### Requirements

- **Root Privileges**: The script requires root access to perform certain operations.
- **Email Configuration**: Ensure that email settings are correctly configured on the system if you plan to use the email notification feature.

### Installation

No installation is required. Simply download the script and make it executable:

`chmod +x syssec_audit.sh`

### License

This script is provided as-is. Use it at your own risk. There is no warranty or support provided.

### Contributing

If you have suggestions or improvements, please submit a pull request or open an issue on the repository.

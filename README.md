# Jenkins Backup Script

This script is designed to back up Jenkins job configurations and upload the backup to a Google Cloud Storage bucket.

## Usage

```bash
./backup_script.sh /path/to/jenkins_home archive.tar.gz
Description
The script performs the following tasks:

Initialization:

Sets JENKINS_HOME and DEST_FILE from the script's arguments.
Defines temporary directories and file names.
Usage Function:

Displays the correct usage of the script if the required arguments are not provided.
Backup Jobs Function:

Recursively backs up Jenkins job configurations (*.xml and nextBuildNumber files) from the JENKINS_HOME directory to a temporary archive directory (ARC_DIR).
Cleanup Function:

Removes the temporary archive directory and the destination file if they exist.
Send File to Bucket Function:

Uploads the backup file to a specified Google Cloud Storage bucket (backup_jobs_jenkins).
Main Function:

Validates the input arguments.
Calls the backup_jobs function to back up the job configurations.
Creates a compressed tarball (archive.tar.gz) of the backup.
Moves the tarball to the specified destination file.
Uploads the backup file to the Google Cloud Storage bucket.
Cleans up temporary files and directories.
Requirements
Google Cloud SDK (gsutil command) installed and configured.
Jenkins installed and running.
Example
./backup_script.sh /var/lib/jenkins archive.tar.gz
This command will back up the Jenkins job configurations from /var/lib/jenkins and save the backup as archive.tar.gz.

License
This script is provided "as is" without any warranty. Use at your own risk.
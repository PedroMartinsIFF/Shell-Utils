#!/bin/bash

readonly JENKINS_HOME="$1"
readonly DEST_FILE="$2"
#readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
readonly TMP_DIR="/tmp"
readonly ARC_NAME="jenkins-backup"
readonly ARC_DIR="${TMP_DIR}/${ARC_NAME}"
readonly TMP_TAR_NAME="${TMP_DIR}/archive.tar.gz"

function usage() {
  echo "usage: $(basename $0) /path/to/jenkins_home archive.tar.gz"
}

function backup_jobs() {
  local run_in_path="$1"
  local rel_depth=${run_in_path#${JENKINS_HOME}/jobs/}

  if [ -d "${run_in_path}" ]; then
    cd "${run_in_path}"

    find . -maxdepth 1 -type d | while read job_name; do
      [ "${job_name}" = "." ] && continue
      [ "${job_name}" = ".." ] && continue
      [ -d "${JENKINS_HOME}/jobs/${rel_depth}/${job_name}" ] && mkdir -p "${ARC_DIR}/jobs/${rel_depth}/${job_name}/"
      find "${JENKINS_HOME}/jobs/${rel_depth}/${job_name}/" -maxdepth 1  \( -name "*.xml" -o -name "nextBuildNumber" \) -print0 | xargs -0 -I {} cp {} "${ARC_DIR}/jobs/${rel_depth}/${job_name}/"
      if [ -f "${JENKINS_HOME}/jobs/${rel_depth}/${job_name}/config.xml" ] && [ "$(grep -c "com.cloudbees.hudson.plugins.folder.Folder" "${JENKINS_HOME}/jobs/${rel_depth}/${job_name}/config.xml")" -ge 1 ] ; then
        #echo "Folder! $JENKINS_HOME/jobs/$rel_depth/$job_name/jobs"
        backup_jobs "${JENKINS_HOME}/jobs/${rel_depth}/${job_name}/jobs"
      else
        true
        #echo "Job! $JENKINS_HOME/jobs/$rel_depth/$job_name"
      fi
    done
    #echo "Done in $(pwd)"
    cd -
  fi
}

function cleanup() {
  rm -rf "${ARC_DIR}"
  rm -f "${DEST_FILE}"
}

function send_file_to_bucket() {
    # Get the name of the file to upload.

    # Get the name of the bucket to upload the file to.
    BUCKET_NAME="backup_jobs_jenkins"

    # Upload the file to the bucket.
    gsutil cp -r "${DEST_FILE}" gs://$BUCKET_NAME

    # Print a message to the user.
    echo "File $DEST_FILE uploaded to bucket $BUCKET_NAME."
    

}

function main() {
  if [ -z "${JENKINS_HOME}" -o -z "${DEST_FILE}" ] ; then
    usage >&2
    exit 1
  fi


  if [ "$(ls -A ${JENKINS_HOME}/jobs/)" ] ; then
    backup_jobs ${JENKINS_HOME}/jobs/
  fi

  cd "${TMP_DIR}"
  tar -czvf "${TMP_TAR_NAME}" "${ARC_NAME}/"*
  cd -
  mv -f "${TMP_TAR_NAME}" "${DEST_FILE}"
  
  send_file_to_bucket
  cleanup

  exit 0
}

main

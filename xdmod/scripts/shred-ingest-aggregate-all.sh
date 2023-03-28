#!/bin/bash
# Example helper script that runs the various commands to
# load Job and Job Performance data into Open XDMoD.
#
# In a production deployment of Open XDMoD, these commands will
# be run as cronjobs under the xdmod user.

if [ `whoami` != 'xdmod' ]; then
    echo "ERROR: This script should only be run as the xdmod user" >&2
    exit 1
fi

# For the purpose of the tutorial we explicitly set the daterange.
yesterday=`date +%Y-%m-%d --date="-1 day"`
tomorrow=`date +%Y-%m-%d --date="+1 day"`

# Load the Slurm accounting log data into Open XDMoD
xdmod-slurm-helper -r hpc --start-time $yesterday --end-time $tomorrow

# Post-process the Slurm logs so they are available in the portal
xdmod-ingestor

# Scan the filesystem for the Job Performance data archives that
# are generated by the PCP software running on the compute nodes.
indexarchives.py -m $yesterday -M $tomorrow

# Generate the job-level performance summary data for all jobs.
summarize_jobs.py

# Load the job-level performance data into Open XDMoD
aggregate_supremm.sh
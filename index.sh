HERE=${BASH_SOURCE%/*}

source $HERE/query-all-jobs.sh
source $HERE/query-jobs-by-dest.sh
source $HERE/query-jobs-by-dest2.sh
source $HERE/query-jobs-by-tool.sh
source $HERE/query-jobs-by-tool2.sh
source $HERE/query-jobs-by-tool-stderr.sh
source $HERE/query-jobs-by-tool-stdout.sh
source $HERE/query-time-size-by-tool.sh
source $HERE/query-jobs-tool-and-stderr.sh

source $HERE/job_errors/query-job-info.sh
source $HERE/job_errors/query-job-stdout.sh
source $HERE/job_errors/query-job-stderr.sh
source $HERE/job_errors/query-tool-stdout.sh
source $HERE/job_errors/query-tool-stderr.sh
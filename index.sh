HERE=${BASH_SOURCE%/*}

source $HERE/query-all-jobs.sh
source $HERE/query-all-jobs2.sh
source $HERE/query-completed-jobs-by-node.sh
source $HERE/query-jobs-by-dest.sh  # join fixed  # to add to usegalaxy-au
source $HERE/query-jobs-by-dest3.sh
source $HERE/query-jobs-by-tool.sh
source $HERE/query-jobs-by-tool2.sh
source $HERE/query-jobs-by-tool-stderr.sh
source $HERE/query-jobs-by-tool-stderr2.sh
source $HERE/query-jobs-by-info.sh
source $HERE/query-jobs-by-tool-stdout.sh
source $HERE/query-time-size-by-tool.sh
source $HERE/query-time-size-by-dest.sh
source $HERE/query-jobs-tool-and-stderr.sh
source $HERE/query-jobs-tool-and-stdout.sh
source $HERE/query-jobs-tool-and-traceback.sh
source $HERE/query-new-job-sizes.sh
source $HERE/query-queued-job-sizes.sh
source $HERE/query-training-members.sh
source $HERE/query-training-members2.sh
source $HERE/query-job-time-output-sizes.sh
source $HERE/query-1slot-jobs-by-walltime.sh
source $HERE/query-walltime-size-by-tool.sh
source $HERE/query-walltime-size-by-tool-with-info.sh
source $HERE/query-jobs-running-at-datetime.sh
source $HERE/query-queue.sh
source $HERE/query-jobs-with-large-outputs.sh
source $HERE/query-destination-params.sh
source $HERE/query-test-for-gxadmin.sh

source $HERE/job_errors/query-job-info.sh
source $HERE/job_errors/query-job-stdout.sh
source $HERE/job_errors/query-job-stderr.sh
source $HERE/job_errors/query-tool-stdout.sh
source $HERE/job_errors/query-tool-stderr.sh
source $HERE/job_errors/query-traceback.sh

source $HERE/grt/query-grt1.sh

source $HERE/query-jobs-012.sh
source $HERE/query-jobs-edit.sh
source $HERE/query-jobs-userdata1.sh
source $HERE/query-jobs-userdata4.sh
source $HERE/query-oom-jobs.sh
source $HERE/query-tool-memory.sh
source $HERE/query-jobs-by-object-store-id.sh
source $HERE/query-general-pulsar-recent.sh
source $HERE/query-pulsar-score.sh

source $HERE/query-command.sh
source $HERE/query-mem.sh

source $HERE/query-deleted-collection-jobs-for-user.sh
source $HERE/query-all-deleted-collection-jobs.sh
source $HERE/query-user-info.sh
source $HERE/query-oom-by-tool.sh

source $HERE/query-job-outputs-by-dest.sh
source $HERE/query-tpv-errors.sh

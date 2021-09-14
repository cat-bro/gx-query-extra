local_query-1slot-jobs-by-walltime() { ## input seconds,  # optional limit
    walltime_seconds="$1"
	[ ! "$2" ] && limit="50" || limit="$2"

	handle_help "$@" <<-EOF

    Produces a table of completed jobs with running time *greater than* the input argument in seconds that have
    run on the slurm_1slot destination.  There is an optional second argument of the number of rows to return
    (default 50).

    For example, the last 4 jobs that ran on slurm_1slot for more than half an hour (1800 seconds)

    gxadmin local query-1slot-jobs-by-walltime 1800 10
     job_id  |        update_time         |                                                   tool_id                                                    | runtime  | sum_input_size
    ---------+----------------------------+--------------------------------------------------------------------------------------------------------------+----------+----------------
     7535177 | 2021-09-14 06:48:04.311428 | toolshed.g2.bx.psu.edu/repos/devteam/fastq_paired_end_interlacer/fastq_paired_end_interlacer/1.2.0.1+galaxy0 | 00:38:25 | 603 MB
     7534756 | 2021-09-14 04:17:04.111619 | toolshed.g2.bx.psu.edu/repos/iuc/scanpy_remove_confounders/scanpy_remove_confounders/1.7.1+galaxy0           | 00:56:32 | 4659 MB
     7534276 | 2021-09-14 03:17:39.812616 | toolshed.g2.bx.psu.edu/repos/iuc/scanpy_remove_confounders/scanpy_remove_confounders/1.7.1+galaxy0           | 01:14:35 | 4659 MB
     7534370 | 2021-09-14 03:14:51.898115 | toolshed.g2.bx.psu.edu/repos/iuc/fastqe/fastqe/0.2.6+galaxy0                                                 | 01:19:38 | 9799 MB

	EOF

	read -r -d '' QUERY <<-EOF
        SELECT
            jmn.job_id as job_id,
            j.update_time as update_time,
            j.tool_id as tool_id,
            TO_CHAR((jmn.metric_value || ' second')::interval, 'HH24:MI:SS') as runtime,
            (
                SELECT
                pg_size_pretty(SUM(d.total_size))
                FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
                WHERE hda.dataset_id = d.id
                AND jtid.job_id = j.id
                AND hda.id = jtid.dataset_id
            ) as sum_input_size
            FROM job_metric_numeric jmn, job j
            WHERE jmn.job_id = j.id
            AND j.destination_id = 'slurm_1slot'
            AND jmn.metric_name = 'runtime_seconds'
            AND jmn.metric_value > $walltime_seconds
            ORDER BY j.update_time desc
            LIMIT $limit
	EOF
}
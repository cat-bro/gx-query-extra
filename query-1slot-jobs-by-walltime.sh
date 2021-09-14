local_query-1slot-jobs-by-walltime() { ## input seconds,  # optional limit
    walltime_seconds="$1"
	[ ! "$2" ] && limit="50" || limit="$2"

	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
        SELECT
            jmn.job_id as job_id,
            j.tool_id as tool_id,
            jmm.metric_value as runtime_seconds,
            TO_CHAR((jmm.metric_value || ' second')::interval, 'HH24:MI:SS') as runtime,
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
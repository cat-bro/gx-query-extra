local_query-tool-memory() { ##? <limit>
	tool_substr="$1"
	[ ! "$2" ] && limit="10" || limit="$2"
	handle_help "$@" <<-EOF

	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.update_time as updated,
				j.tool_id as tool_id,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as cores,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'mem=(\d+)'))[1] as mem,
				(
					SELECT
					pg_size_pretty(SUM(d.total_size))
					FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
					WHERE hda.dataset_id = d.id
					AND jtid.job_id = j.id
					AND hda.id = jtid.dataset_id
				) as sum_input_size,
				(SELECT 
					pg_size_pretty(jmn.metric_value)
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'memory.max_usage_in_bytes'
					AND jmn.job_id = j.id
				) as runtime,
				(SELECT 
					TO_CHAR((jmn.metric_value || ' second')::interval, 'HH24:MI:SS')
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'runtime_seconds'
					AND jmn.job_id = j.id
				) as runtime,
				j.destination_id as destination
			FROM job j
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}
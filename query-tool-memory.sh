local_query-tool-memory() { ##? <limit>
	tool_substr="$1"
	[ ! "$2" ] && limit="10" || limit="$2"
	handle_help "$@" <<-EOF

	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.update_time as updated,
				j.state as state,
				j.tool_id as tool_id,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as tpv_cores,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'mem=(\d+)'))[1] as tpv_mem_mb,
				(
					SELECT
					pg_size_pretty(SUM(total_size))
					FROM (
						SELECT distinct hda.id as hda_id, d.total_size as total_size
						FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
						WHERE hda.dataset_id = d.id
						AND jtid.job_id = j.id
						AND hda.id = jtid.dataset_id
					) as kris
				) as input_size,
				(SELECT 
					pg_size_pretty(jmn.metric_value)
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'memory.max_usage_in_bytes'
					AND jmn.job_id = j.id
				) as job_max_mem,
				(SELECT 
					TO_CHAR((jmn.metric_value || ' second')::interval, 'HH24:MI:SS')
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'runtime_seconds'
					AND jmn.job_id = j.id
				) as runtime,
				j.destination_id as destination
			FROM job j
			WHERE position('$tool_substr' in j.tool_id)>0
			AND j.state in ('ok', 'error')
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}
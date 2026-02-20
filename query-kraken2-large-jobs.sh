local_query-kraken2-large-jobs() { ##? <limit>
	tool_substr="/kraken2/kraken2/"
	[ ! "$1" ] && limit="50" || limit="$1"
	handle_help "$@" <<-EOF

  Getting info on kraken jobs using large databases
  
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.update_time as updated,
				j.state as state,
				j.tool_version as tool_version,
        position('--report' in j.command_line)>0 as report_in_command,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as tpv_cores,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'mem=(\d+)'))[1] as tpv_mem_mb,
				(
					SELECT pg_size_pretty(SUM(total_size))
					FROM (
						SELECT DISTINCT hda.id as hda_id, d.total_size as total_size
						FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
						WHERE hda.dataset_id = d.id
						AND jtid.job_id = j.id
						AND hda.id = jtid.dataset_id
					) as foo
				) as input_size,
				(SELECT LAST
					pg_size_pretty(jmn.metric_value)
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'memory.max_usage_in_bytes'
					AND jmn.job_id = j.id
				) as job_max_mem,
				(SELECT LAST
					TO_CHAR((jmn.metric_value || ' second')::interval, 'HH24:MI:SS')
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'runtime_seconds'
					AND jmn.job_id = j.id
				) as runtime,
				j.destination_id as destination
			FROM job j
			WHERE position('$tool_substr' in j.tool_id)>0
			AND j.state in ('ok')
      AND (SELECT LAST jmn.metric_value FROM job_metric_numeric jmn WHERE jmn.metric_name = 'galaxy_memory_mb' AND jmn.job_id = j.id) > 200000
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}

local_query-pulsar-score() { ##? <limit>

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
					SUM(total_size)
					FROM (
						SELECT distinct hda.id as hda_id, d.total_size as total_size
						FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
						WHERE hda.dataset_id = d.id
						AND jtid.job_id = j.id
						AND hda.id = jtid.dataset_id
					) as foo
				) as input_size,
				(
					SELECT
					SUM(total_size)
					FROM (
						SELECT distinct hda.id as hda_id, d.total_size as total_size
						FROM dataset d, history_dataset_association hda, job_to_output_dataset jtod
						WHERE hda.dataset_id = d.id
						AND jtod.job_id = j.id
						AND hda.id = jtod.dataset_id
					) as foo
				) as output_size,
				(SELECT 
					jmn.metric_value
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'runtime_seconds'
					AND jmn.job_id = j.id
				) as runtime_seconds,
			destination_id as destination_id
			FROM job j
			WHERE position('$tool_substr' in j.tool_id)>0
			AND j.update_time > NOW() - INTERVAL '30 days'
			AND j.state in ('ok', 'error')
			ORDER BY j.update_time desc
	EOF
}
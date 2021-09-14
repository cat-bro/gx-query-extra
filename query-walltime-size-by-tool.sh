local_query-walltime-size-by-tool() { ##? <tool> input tool substr,  # optional <limit>
	tool_substr="$1"
	[ ! "$2" ] && limit="10" || limit="$2"
	handle_help "$@" <<-EOF
	EOF


	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				j.update_time as updated,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
                TO_CHAR((jmn.metric_value || ' second')::interval, 'HH24:MI:SS') as runtime,
				(
					SELECT
					pg_size_pretty(SUM(d.total_size))
					FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
					WHERE hda.dataset_id = d.id
					AND jtid.job_id = j.id
					AND hda.id = jtid.dataset_id
				) as sum_input_size,
				j.destination_id as destination
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
			AND position('$tool_substr' in j.tool_id)>0
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}
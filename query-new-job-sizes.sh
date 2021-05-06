local_query-new-job-sizes() { ##? <tool> input tool substr,  # optional <limit>
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
				(
					SELECT
					pg_size_pretty(SUM(d.total_size))
					FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
					WHERE hda.dataset_id = d.id
					AND jtid.job_id = j.id
					AND hda.id = jtid.dataset_id
				) as sum_input_size,
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
			AND position('$tool_substr' in j.tool_id)>0
			ORDER BY j.create_time desc

	EOF
}

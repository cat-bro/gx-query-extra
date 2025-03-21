local_query-queued-job-sizes() { ##? <tool> input tool substr,  # optional <limit>
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				(
					SELECT MAX(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state = 'queued'
				) as queued_time,
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
                j.destination_id as destination_id
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
            AND j.state = 'queued'
			ORDER BY j.create_time desc

	EOF
}

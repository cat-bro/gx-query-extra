local_query-jobs-with-large-outputs() { ##? <tool> input tool substr,  # optional <limit>
	[ ! "$2" ] && limit="50" || limit="$2"
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
				(
					SELECT
					SUM(d.total_size)
					FROM dataset d, history_dataset_association hda, job_to_out_dataset jtod
					WHERE hda.dataset_id = d.id
					AND jtod.job_id = j.id
					AND hda.id = jtod.dataset_id
				) as sum_input_size,
				j.destination_id as destination,
				j.job_runner_external_id as external_id
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
            AND sum_input_size > 50000000000
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}

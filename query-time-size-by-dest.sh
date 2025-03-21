local_query-time-size-by-dest() { ##? <tool> input tool substr,  # optional <limit>
	dest_substr="$1"
	[ ! "$2" ] && limit="10" || limit="$2"
	handle_help "$@" <<-EOF
	EOF


	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				j.update_time as updated,
				(
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state in ('running', 'ok', 'error', 'deleted')) -
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state in ('new', 'queued'))
				) as queue_time,
				(
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state in ('error', 'deleted', 'ok')) -
					(SELECT MAX(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state in ('running'))
				) as run_time,
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
				j.destination_id as destination,
				j.job_runner_external_id as external_id
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
			AND position('$dest_substr' in j.destination_id)>0
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}

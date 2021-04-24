local_query-jobs-by-tool2() { ## input tool substr,  # optional limit
	tool_substr="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				(
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state = 'running') -
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state = 'queued')
				) as queue_time,
				(
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state in ('error', 'deleted', 'ok')) -
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state = 'running')
				) as run_time,
				j.update_time as updated,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination,
				j.job_runner_external_id as external_id
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
			AND position('$tool_substr' in j.tool_id)>0
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}

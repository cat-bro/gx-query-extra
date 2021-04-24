local_query-jobs-by-tool() { ## input tool substr,  # optional limit
	tool_substr="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				j.update_time - j.create_time as duration,
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

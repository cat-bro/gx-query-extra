local_query-jobs-by-dest2() { ## input destination substr,  # optional limit
	dest_substr="$1"
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
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as cores,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'mem=(\d+)'))[1] as mem,
				j.destination_id as destination,
				j.job_runner_external_id as external_id
			FROM job j
			FULL OUTER JOIN galaxy_user u ON j.user_id = u.id
			WHERE j.user_id = u.id
			AND position('$dest_substr' in j.destination_id)>0
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}
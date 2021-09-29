local_query-jobs-running-at-datetime() {
	datetime="$1"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
                j.update_time as updated,
				j.user_id as user_id,
				j.state as state,
				j.tool_id as tool_id,
                j.destination_id as destination_id
			FROM job j
            WHERE j.create_time < '$datetime'
			AND j.update_time > '$datetime'
			AND j.state in ('queued', 'running', 'ok')
			ORDER BY j.create_time desc
	EOF
}
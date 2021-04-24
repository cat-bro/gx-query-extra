local_query-jobs-by-tool-stderr() { ## input destination substr,  # optional limit
	tool_stderr_substr="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination
			FROM job j
			WHERE position('$tool_stderr_substr' in j.tool_stderr)>0
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}

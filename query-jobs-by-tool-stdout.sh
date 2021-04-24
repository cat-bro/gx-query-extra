local_query-jobs-by-tool-stdout() { ## input destination substr,  # optional limit
	tool_stdout_substr="$1"
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
			WHERE position('$tool_stdout_substr' in j.tool_stdout)>0
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}
local_query-jobs-by-info() { ## input destination substr,  # optional limit
	job_info_substr="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.update_time as updated,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination
			FROM job j
			WHERE position('$job_info_substr' in j.info)>0
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}

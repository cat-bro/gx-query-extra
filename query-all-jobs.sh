local_query-all-jobs() { ## input limit,  # optional string of more clauses
	[ ! "$1" ] && limit="50" || limit="$1"
	# [ ! "$2" ] || more_clauses="AND $2"
	# [ ! "$more_clauses" ] && where_clause="j.user_id = u.id" || where_clause="j.user_id = u.id $more_clauses"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}

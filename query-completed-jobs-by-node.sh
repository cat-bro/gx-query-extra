local_completed-jobs-by-node() { ## input limit,  # optional string of more clauses
    host_name="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	# [ ! "$2" ] || more_clauses="AND $2"
	# [ ! "$more_clauses" ] && where_clause="j.user_id = u.id" || where_clause="j.user_id = u.id $more_clauses"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				jmt.job_id as job_id,
				j.update_time as updated,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination,
				jmt.metric_value as node,
			FROM job j, galaxy_user u, job_metric_text jmt
			WHERE j.user_id = u.id
			AND jmt.job_id = j.id
			AND jmt.metric_name = 'HOSTNAME'
            AND j.state in ('ok', 'deleted', 'error')
            AND hostname = $host_name
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}
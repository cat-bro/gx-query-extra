local_completed-jobs-by-node() { ## input limit,  # optional string of more clauses
    host_name="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
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
				j.destination_id as destination,
                (SELECT jmt.metric_value from job_metric_text jmt where 
                jmt.metric_name = 'HOSTNAME' and jmt.job_id = j.id) as hostname
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
            AND j.state in ('ok', 'deleted', 'error')
            AND hostname = $host_name
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}
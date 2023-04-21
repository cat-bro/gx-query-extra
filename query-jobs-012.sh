local_query-jobs-012() { ## input limit,  # optional string of more clauses
	[ ! "$1" ] && limit="50" || limit="$1"
	# [ ! "$2" ] || more_clauses="AND $2"
	# [ ! "$more_clauses" ] && where_clause="j.user_id = u.id" || where_clause="j.user_id = u.id $more_clauses"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				j.user_id,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination
			FROM job j
				JOIN job_to_input_dataset jtid
					ON j.id = jtid.job_id
				JOIN history_dataset_association hda
					ON hda.id = jtid.dataset_id
				JOIN dataset d
					ON hda.dataset_id = d.id
			WHERE
				d.create_time < '2023-03-17 01:26:07'
			AND
				d.create_time > '2023-03-03 07:04:21'
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}

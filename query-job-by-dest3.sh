local_query-jobs-by-dest3() { ## input destination substr,  # optional limit
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
				j.destination_id as destination,
				j.job_runner_external_id as external_id,
                (SELECT jmt.metric_value from job_metric_text jmt where 
                jmt.metric_name = 'HOSTNAME' and jmt.job_id = j.id) as hostname
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
			AND position('$dest_substr' in j.destination_id)>0
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}
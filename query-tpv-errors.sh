local_query-tpv-errors() { ##? <limit> : Show most recent jobs with tpv error messages in info
	[ ! "$1" ] && limit="50" || limit="$1"
	handle_help "$@" <<-EOF

	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				u.username,
				j.update_time as updated,
				j.tool_id as tool_id,
				(
					SELECT pg_size_pretty(SUM(total_size))
					FROM (
						SELECT DISTINCT hda.id as hda_id, d.total_size as total_size
						FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
						WHERE hda.dataset_id = d.id
						AND jtid.job_id = j.id
						AND hda.id = jtid.dataset_id
					) as foo
				) as input_size,
				j.destination_id as destination
			FROM job j
			FULL OUTER JOIN galaxy_user u ON j.user_id = u.id
			WHERE j.user_id = u.id
			AND (
				position('No destinations' in j.info)>0
				OR position('exception while caching job destination dynamic rule' in j.info)>0
			)
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}

local_query-jobs-by-object-store-id() { ## [object_store_id]: Substring of object store backend ID, optional limit as second arg
	object_store_id="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT DISTINCT
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
				d.object_store_id ~ $object_store_id
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}
local_query-job-outputs-by-dest() { ##? [job_id] : Show job output datasets with sizes for a job destination
	# similar to gxadmin query-job-outputs but with sizes and dataset uuids
	arg_dest_substr="$1"
  [ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF
	Shows recent output datasets with file_size and total size for a given destination substring

	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				hda.id AS hda_id,
				hda.name AS hda_name,
				d.id AS d_id,
				d.state AS d_state,
				pg_size_pretty(d.file_size) AS file_size,
				pg_size_pretty(d.total_size) AS total_size,
				d.uuid as d_uuid,
				d.object_store_id as object_store_id,
        j.update_time as update_time,
        j.destination_id as destination_id
			FROM job j
				JOIN job_to_output_dataset jtod
					ON j.id = jtod.job_id
				JOIN history_dataset_association hda
					ON hda.id = jtod.dataset_id
				JOIN dataset d
					ON hda.dataset_id = d.id
			WHERE position('$arg_dest_substr' in j.destination_id)>0
			AND j.state = 'ok'
      ORDER BY j.update_time desc
	  LIMIT $limit
	EOF
}

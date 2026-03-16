local_query-history-exports() { ##? <limit> : Show most recent history exports
	[ ! "$1" ] && limit="50" || limit="$1"
	handle_help "$@" <<-EOF

	Show most recent history export tasks with an optional argument for number of rows returned (default 50).


	EOF

	read -r -d '' QUERY <<-EOF
	    SELECT
	      sea.id AS id,
	      sea.create_time::timestamp(0) AS create_time,
	      sea.task_uuid AS task_uuid,
	      sea.object_id AS history_iud,
	      h.user_id,
	      (
	        SELECT
	          pg_size_pretty(sum(coalesce(d.total_size, d.file_size, 0)))
	          FROM history_dataset_association hda, dataset d
	          WHERE hda.dataset_id = d.id
	          AND hda.history_id = h.id
	      ) AS total_size,
	    FROM store_export_association sea, history h
	    WHERE sea.object_type = 'history'
	    AND h.id = sea.object_id
	    ORDER BY sea.create_time desc
	    LIMIT $limit
  EOF
}

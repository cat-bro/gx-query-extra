local_query-history-exports() { ##? <limit> : Show most recent history exports
	[ ! "$1" ] && limit="50" || limit="$1"
	handle_help "$@" <<-EOF

	Show most recent history export tasks with an optional argument for number of rows returned (default 50).

	$ gxadmin local query-history-exports 3
	  id  |     create_time     |            task_uuid             | history_id | user_id | total_size |                  result_data
	------+---------------------+----------------------------------+------------+---------+------------+-----------------------------------------------
	 3275 | 2026-03-15 10:27:25 | 5557cfe535c34c959baa7e7fa4ecddc6 |    2800101 |   12345 | 149 GB     | {"uri": null, "error": null, "success": true}
	 3274 | 2026-03-14 05:13:12 | 555611b2b02d4ec59a9246b73bbdda15 |    2840202 |   42424 | 11 GB      | {"uri": null, "error": null, "success": true}
	 3273 | 2026-03-14 04:08:40 | 555c6a5a7eb44836a1c8a705bcfa7714 |    2790303 |   23456 | 279 GB     | {"uri": null, "error": null, "success": true}
	(3 rows)

	EOF

	read -r -d '' QUERY <<-EOF
		    SELECT
		      sea.id as id,
		      sea.create_time::timestamp(0) as create_time,
		      sea.task_uuid as task_uuid,
		      sea.object_id as history_id,
		      h.user_id as user_id,
		      (
		        SELECT
		          pg_size_pretty(sum(coalesce(d.total_size, d.file_size, 0)))
		          FROM history_dataset_association hda, dataset d
		          WHERE hda.dataset_id = d.id
		          AND hda.history_id = h.id
		      ) as total_size,
			((CONVERT_FROM(sea.export_metadata, 'UTF8')::jsonb #>> '{}')::jsonb -> 'result_data') as result_data
		    FROM store_export_association sea, history h
		    WHERE sea.object_type = 'history'
		    AND h.id = sea.object_id
		    ORDER BY sea.create_time desc
		    LIMIT $limit;
EOF
}

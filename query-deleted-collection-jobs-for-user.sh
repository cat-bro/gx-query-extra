local_query-deleted-collection-jobs-for-user() { ##? [user_id] <limit>
	user_id="$1"
    [ ! "$1" ] && echo "Please provide a user ID" && exit 0
	[ ! "$2" ] && limit="10000" || limit="$2"
	handle_help "$@" <<-EOF

    For a user ID, output a row for each job in new, queued, running state
    that has no non-deleted collection outputs. Optional limit as second argument

    $ gxadmin local query-deleted-collection-jobs-for-user 24601 3
      job_id  |        update_time         |  state  | tool_id  | history_name | all_hdca_deleted |  latest_hdca_update_time
    ----------+----------------------------+---------+----------+--------------+------------------+----------------------------
     19021030 | 2025-04-23 09:38:12.815153 | new     | read_dna |  Amphibian   | t                | 2025-04-24 06:08:36.660023
     19021031 | 2025-04-23 09:38:13.169037 | new     | read_dna |  Amphibian   | t                | 2025-04-24 06:08:36.660023
     19021032 | 2025-04-23 09:38:13.169037 | new     | read_dna |  Amphibian   | t                | 2025-04-24 06:08:36.660023
	EOF

	read -r -d '' QUERY <<-EOF
		SELECT
			j.id AS job_id,
			j.update_time,
			j.state,
			j.tool_id as tool_id,
			h.name AS history_name,
			BOOL_AND(hdca.deleted) AS all_hdca_deleted,
			MAX(hdca.update_time) AS latest_hdca_update_time
		FROM job j
		JOIN job_to_output_dataset jtid ON j.id = jtid.job_id
		JOIN history_dataset_association hda ON jtid.dataset_id = hda.id
		JOIN history h ON hda.history_id = h.id
		JOIN dataset_collection_element dce ON dce.hda_id = hda.id
		JOIN dataset_collection dc ON dce.dataset_collection_id = dc.id
		JOIN history_dataset_collection_association hdca ON dc.id = hdca.collection_id
		WHERE j.user_id = '$user_id'
		AND j.state IN ('new', 'queued', 'running')
		GROUP BY j.id, j.state, h.name, h.id, h.deleted
        HAVING BOOL_AND(hdca.deleted) = TRUE
		ORDER BY j.id
		LIMIT '$limit';

	EOF
}
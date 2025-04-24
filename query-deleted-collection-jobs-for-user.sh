local_query-deleted-collection-jobs-for-user() { ##? <limit>
	user_id="$1"
	[ ! "$2" ] && limit="10000" || limit="$2"
	echo $limit
	handle_help "$@" <<-EOF

	EOF

	read -r -d '' QUERY <<-EOF
		SELECT
			j.id AS job_id,
			j.state,
			h.name AS history_name,
			h.id AS history_id,
			h.deleted AS history_deleted,
			BOOL_AND(hdca.deleted) AS all_hdca_deleted
		FROM job j
		JOIN job_to_output_dataset jtid ON j.id = jtid.job_id
		JOIN history_dataset_association hda ON jtid.dataset_id = hda.id
		JOIN history h ON hda.history_id = h.id
		JOIN dataset_collection_element dce ON dce.hda_id = hda.id
		JOIN dataset_collection dc ON dce.dataset_collection_id = dc.id
		JOIN history_dataset_collection_association hdca ON dc.id = hdca.collection_id
		WHERE j.user_id = '$user_id'
		AND j.state IN ('new', 'queued', 'running')
        HAVING BOOL_AND(hdca.deleted) = TRUE
		GROUP BY j.id, j.state, h.name, h.id, h.deleted
		ORDER BY j.id
		LIMIT '$limit';

	EOF
}
local_query-job-output-datasets() { ##? <id>: Job ID
	# similar to gxadmin query-job-inputs but with sizes
	arg_id="$1"
	handle_help "$@" <<-EOF
	Shows a table of job output datasets with file_size and total size for a given job id
	
	$ gxadmin local query-job-output-datasets 4092986755

	 hda_id  |            hda_name             |  d_id   | d_state | d_file_size | d_total_size
	---------+---------------------------------+---------+---------+-------------+--------------
	91237625 | SRR7692603:forward uncompressed | 3545195 | ok      | 4810 MB     | 4810 MB
	91237627 | SRR7692603:reverse uncompressed | 3545196 | ok      | 4845 MB     | 4845 MB

	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				hda.id AS hda_id,
				hda.name AS hda_name,
                hda.extension AS extension,
				d.id AS d_id,
				d.state AS d_state,
				pg_size_pretty(d.file_size) AS d_file_size,
				pg_size_pretty(d.total_size) AS d_total_size
			FROM job j
				JOIN job_to_output_dataset jtod
					ON j.id = jtod.job_id
				JOIN history_dataset_association hda
					ON hda.id = jtod.dataset_id
				JOIN dataset d
					ON hda.dataset_id = d.id
			WHERE j.id = $arg_id
	EOF
}
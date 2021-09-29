local_query-job-output-datasets() { ##? <id>: Job ID
	# similar to gxadmin query-job-inputs but for outputs including file sizes
	arg_id="$1"
	handle_help "$@" <<-EOF
	Shows a table of job output datasets with file_size and total size for a given job id
	
	$ gxadmin local query-job-output-datasets 2996484
	 hda_id  |                  hda_name                  | extension |  d_id   | d_state | d_file_size | d_total_size
	---------+--------------------------------------------+-----------+---------+---------+-------------+--------------
	 6073903 | TopHat on data  TY5_N 39: align_summary    | txt       | 5301465 | ok      | 203 bytes   | 203 bytes
	 6073904 | TopHat on data  TY5_N 39: insertions       | bed       | 5301466 | ok      | 6458 kB     | 6458 kB
	 6073905 | TopHat on data  TY5_N 39: deletions        | bed       | 5301467 | ok      | 5760 kB     | 5760 kB
	 6073906 | TopHat on data  TY5_N 39: splice junctions | bed       | 5301468 | ok      | 3589 kB     | 3589 kB
	 6073907 | TopHat on data TY5_N 39: accepted_hits     | bam       | 5301469 | ok      | 1982 MB     | 1982 MB

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
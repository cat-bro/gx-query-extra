local_query-oom-by-tool() { ##? <limit> : Show most recent jobs with 'Killed' in tool_stderr or 'terminated because it used more memory' in info
	tool_substr="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF

	Produces a table of jobs that have failed due to out of memory errors.
	Optional argument of number of rows to return (default: 50).

	$ gxadmin local query-oom-jobs 3
	   id    | username |        create_time         |                             tool_id                             | cores | mem_mb |   input_size   |    destination_id
	---------+----------+----------------------------+-----------------------------------------------------------------+-------+--------+----------------+----------------------
	 6994190 | anthony  | 2023-08-30 22:26:38.904458 | toolshed.g2.bx.psu.edu/repos/iuc/minimap2/minimap2/2.20+galaxy2 | 16    | 62874  | 8947 MB        | pulsar-QLD
	 6993519 | bob      | 2023-08-30 16:16:13.27616  | toolshed.g2.bx.psu.edu/repos/chemteam/bio3d_pca/bio3d_pca/2.3.4 | 1     | 65536  | 5667 MB        | pulsar-qld-high-mem1
	 6993500 | julia    | 2023-08-30 16:01:10.09834  | toolshed.g2.bx.psu.edu/repos/iuc/abyss/abyss-pe/2.3.6+galaxy0   | 16    | 62874  | 22 MB          | pulsar-mel3
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				u.username,
				j.update_time as updated,
				j.tool_id as tool_id,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as cores,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'mem=(\d+)'))[1] as mem,
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
				position('This job was terminated because it used more memory' in j.info)>0
				OR position('Killed' in j.tool_stderr)>0
				OR position('Some of your processes may have been killed' in j.tool_stderr)>0
				OR position('Some of your processes may have been killed' in j.job_stderr)>0
			)
			AND position('$tool_substr' in j.tool_id)>0
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}


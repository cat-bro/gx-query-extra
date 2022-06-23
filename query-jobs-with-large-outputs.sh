local_query-job-output-size-by-tool() { ##? <tool> input tool substr,  # optional <limit>
	[ ! "$2" ] && limit="10" || limit="$2"
	handle_help "$@" <<-EOF

	Produces a table of n most recently created jobs for a tool.  The first argument is a substring of the tool ID.
	The second optional argument is the number of rows to display (default 10).
	**NOTE**: since the tool argument is a substring of the ID, to specifically look for bwa jobs without including
	bwa_mem jobs the appropriate argument would be '/bwa/bwa/'

	$ gxadmin local query-jobs-input-size-by-tool multiqc

	 job_id  |          created           |          updated           |   username   | state |                       tool_id                        | sum_input_size | destination  | external_id
	---------+----------------------------+----------------------------+--------------+-------+------------------------------------------------------+----------------+--------------+-------------
	 4212521 | 2021-03-01 23:40:43.571578 | 2021-03-01 23:40:57.23172  | platypus     | ok    | toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.9 | 27 kB          | slurm_3slots | 492
	 4212432 | 2021-03-01 23:19:33.729478 | 2021-03-01 23:19:46.422826 | emu          | ok    | toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.9 | 18 kB          | slurm_3slots | 460
	 4212427 | 2021-03-01 23:15:36.339832 | 2021-03-01 23:15:46.32736  | koala        | ok    | toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.9 | 18 kB          | slurm_3slots | 446
	 4212426 | 2021-03-01 23:15:20.785234 | 2021-03-01 23:15:32.484563 | wombat       | ok    | toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.9 | 27 kB          | slurm_3slots | 445
	 4212421 | 2021-03-01 23:14:05.770694 | 2021-03-01 23:14:12.965732 | koala        | error | toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.9 | 1615 kB        | slurm_3slots | 444

	EOF


	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				j.update_time as updated,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
				(
					SELECT
					pg_size_pretty(SUM(d.total_size))
					FROM dataset d, history_dataset_association hda, job_to_output_dataset jtod
					WHERE hda.dataset_id = d.id
					AND jtod.job_id = j.id
					AND hda.id = jtod.dataset_id
				) as sum_input_size,
				j.destination_id as destination,
				j.job_runner_external_id as external_id
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
			AND j.user_id = 15958
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}

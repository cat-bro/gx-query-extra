local_query-grt1() { ##? <tool> input tool substr,  # optional <limit>
	tool_substr="$1"
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF

    Produces a table with input size and running times for a given tool, provided as the first argument.
    The argument is a substring of the tool_id e.g. trinity, trinity/2.9.1+galaxy1, Count1.  The second
    argument is the number of rows to return (optional, default: 50).

    gxadmin local query-walltime-size-by-tool busco 5
     job_id  |          created           |          updated           |   username    |  state  |                          tool_id                           | runtime  | sum_input_size | destination
    ---------+----------------------------+----------------------------+---------------+---------+------------------------------------------------------------+----------+----------------+--------------
     7535204 | 2021-09-14 06:13:44.820678 | 2021-09-14 07:27:47.494749 | julia         | ok      | toolshed.g2.bx.psu.edu/repos/iuc/busco/busco/5.0.0+galaxy0 | 01:13:59 | 148 MB         | slurm_3slots
     7533738 | 2021-09-13 14:10:02.462621 | 2021-09-13 18:06:15.366452 | paul          | ok      | toolshed.g2.bx.psu.edu/repos/iuc/busco/busco/5.2.2+galaxy0 | 03:56:10 | 31 MB          | slurm_1slot
     7533781 | 2021-09-13 14:53:51.879839 | 2021-09-13 14:54:24.656188 | kevin         | ok      | toolshed.g2.bx.psu.edu/repos/iuc/busco/busco/5.2.2+galaxy0 | 00:00:31 | 2244 kB        | slurm_1slot
     7533323 | 2021-09-13 08:15:12.673086 | 2021-09-13 12:10:33.847549 | paul          | ok      | toolshed.g2.bx.psu.edu/repos/iuc/busco/busco/5.2.2+galaxy0 | 03:55:18 | 31 MB          | slurm_1slot
     7533213 | 2021-09-13 05:59:59.559287 | 2021-09-13 07:21:51.458181 | paul          | deleted | toolshed.g2.bx.psu.edu/repos/iuc/busco/busco/5.2.2+galaxy0 |          | 3970 MB        | slurm_3slots
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				j.state as state,
				j.tool_id as tool_id,
                (SELECT 
                    TO_CHAR((jmn.metric_value || ' second')::interval, 'HH24:MI:SS')
                    FROM api_metricnumeric jmn
                    WHERE jmn.metric_name = 'runtime_seconds'
                    AND jmn.external_job_id = j.external_job_id
                ) as runtime,
				(
					SELECT
					pg_size_pretty(SUM(d.total_size))
					FROM api_dataset d
					WHERE d.external_job_id = j.external_job_id
				) as sum_input_size
			FROM api_job j
			LIMIT $limit
	EOF
}


local_query-mem() { ##? <limit>
        echo $1 $2 $3
	tool_substr="$1"
	[ ! "$2" ] && mem_arg="0" || mem_arg=$(echo "${2} * 1024 * 1024 * 1024" | bc )
	[ ! "$3" ] && limit="50" || limit="$3"
	echo $limit
	echo $3
	handle_help "$@" <<-EOF

	For a substring of a tool ID, list the most recent jobs with annotated with
	    tpv_cores, tpv_mem_mb (the cores and memory allocated to the job)
		input_size (the sum of the input file sizes)
		job_max_mem (from the cgroup job metric value memory.max_usage_in_bytes)
		runtime (from the job metric runtime_seconds)
	The is an optional second argument of number of rows to return (default 50)

	$gxadmin local query-tool-memory flye 3
	 job_id  |          updated           | state |                            tool_id                             | tpv_cores | tpv_mem_mb | input_size | job_max_mem | runtime  |     destination
	---------+----------------------------+-------+----------------------------------------------------------------+-----------+------------+------------+-------------+----------+----------------------
	 6999140 | 2023-09-05 10:19:45.517908 | ok    | toolshed.g2.bx.psu.edu/repos/bgruening/flye/flye/2.9.1+galaxy0 | 120       | 1968128    | 34 GB      | 728 GB      | 42:01:32 | pulsar-qld-high-mem1
	 7020524 | 2023-09-05 08:32:40.891413 | ok    | toolshed.g2.bx.psu.edu/repos/bgruening/flye/flye/2.9.1+galaxy0 | 16        | 62874      | 420 MB     | 9186 MB     | 00:11:28 | pulsar-mel3
	 7020514 | 2023-09-05 08:19:25.951317 | ok    | toolshed.g2.bx.psu.edu/repos/bgruening/flye/flye/2.9.1+galaxy0 | 8         | 31437      | 207 MB     | 8991 MB     | 00:03:40 | pulsar-mel3

	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.update_time as updated,
				j.state as state,
				j.tool_id as tool_id,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as tpv_cores,
				(REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'mem=(\d+)'))[1] as tpv_mem_mb,
				(
					SELECT
					pg_size_pretty(SUM(total_size))
					FROM (
						SELECT distinct hda.id as hda_id, d.total_size as total_size
						FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
						WHERE hda.dataset_id = d.id
						AND jtid.job_id = j.id
						AND hda.id = jtid.dataset_id
					) as foo
				) as input_size,
				(SELECT
					pg_size_pretty(jmn.metric_value)
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'memory.max_usage_in_bytes'
					AND jmn.job_id = j.id
				) as job_max_mem,
				(SELECT
					TO_CHAR((jmn.metric_value || ' second')::interval, 'HH24:MI:SS')
					FROM job_metric_numeric jmn
					WHERE jmn.metric_name = 'runtime_seconds'
					AND jmn.job_id = j.id
				) as runtime,
				j.destination_id as destination
			FROM job j
			WHERE position('$tool_substr' in j.tool_id)>0
			AND j.state in ('ok', 'error')
			AND (SELECT jmn.metric_value FROM job_metric_numeric jmn WHERE jmn.metric_name = 'memory.max_usage_in_bytes' AND jmn.job_id = j.id) > $mem_arg
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}

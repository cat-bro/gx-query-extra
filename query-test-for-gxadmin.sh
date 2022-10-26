local_query-jobs() {  ## [--tool] [--dest|--destination] [--states|--terminal|--nonterminal] [--limit]
	handle_help "$@" <<-EOF
	EOF

	tool_id_substr=''
	limit=50
	# states='new,queued,running,ok,deleted,error'  # no good, we want this to be optional

	if (( $# > 0 )); then
		for args in "$@"; do
			if [ "${args:0:7}" = '--tool=' ]; then
				tool_id_substr="${args:7}"
			elif [ "${args:0:8}" = '--limit=' ]; then
				limit="${args:8}"
			elif [ "${args:0:7}" = '--dest=' ]; then
				destination_id_substr="${args:7}"
			elif [ "${args:0:14}" = '--destination=' ]; then
				destination_id_substr="${args:14}"
			elif [ "${args:0:10}" = '--terminal' ]; then
				states="ok,deleted,error"
			elif [ "${args:0:13}" = '--nonterminal' ]; then
				states="new,queued,running"
			elif [ "${args:0:9}" = '--state=' ]; then
				states="${args:9}"
			elif [ "${args:0:9}" = '--user=' ]; then
				user="${args:7}"
			fi
		done
	fi

	states="'$(echo "$states" | sed "s/,/', '/g")'"

	# state_filter() {
	# 	if [ "$states "]; then
	# 		states="'$(echo "$states" | sed "s/,/', '/g")'"
	# 		echo 'AND states in $states'
	# 	fi
	# }


	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time::timestamp(0) as create_time,
				j.update_time::timestamp(0) as update_time,
				j.user_id as user_id,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination,
				j.job_runner_external_id as external_id
			FROM job j
			WHERE position('$destination_id_substr' in j.destination_id)>0
			AND position('$tool_id_substr' in j.tool_id)>0
			AND state in ($states)
			ORDER BY j.update_time desc
			LIMIT $limit
	EOF
}


local_query-job-info() { ## <-|job_id [job_id [...]]> : Retrieve information about jobs given some job IDs
	handle_help "$@" <<-EOF
		Retrieves information on a job, like the host it ran on,
		how long it ran for and the total memory.

		id    | create_time  | update_time |  tool_id     | state |   hostname   | handler  | runtime_seconds | memtotal
		----- | ------------ | ----------- | ------------ | ----- | ------------ | -------- | --------------- | --------
		1     |              |             | 123f911b5f1  | ok    | 123f911b5f1  | handler0 |          20.35  | 20.35 GB
		2     |              |             | cb0fabc0002  | ok    | cb0fabc0002  | handler1 |          14.93  |  5.96 GB
		3     |              |             | 7e9e9b00b89  | ok    | 7e9e9b00b89  | handler1 |          14.24  |  3.53 GB
		4     |              |             | 42f211e5e87  | ok    | 42f211e5e87  | handler4 |          14.06  |  1.79 GB
		5     |              |             | 26cdba62c93  | error | 26cdba62c93  | handler0 |          12.97  |  1.21 GB
		6     |              |             | fa87cddfcae  | ok    | fa87cddfcae  | handler1 |           7.01  |   987 MB
		7     |              |             | 44d2a648aac  | ok    | 44d2a648aac  | handler3 |           6.70  |   900 MB
		8     |              |             | 66c57b41194  | ok    | 66c57b41194  | handler1 |           6.43  |   500 MB
		9     |              |             | 6b1467ac118  | ok    | 6b1467ac118  | handler0 |           5.45  |   250 MB
		10    |              |             | d755361b59a  | ok    | d755361b59a  | handler2 |           5.19  |   100 MB
	EOF

	assert_count_ge $# 1 "Missing job IDs"

	if [[ "$1" == "-" ]]; then
		# read jobs from stdin
		job_ids=$(cat | paste -s -d' ')
	else
		# read from $@
		job_ids=$@;
	fi

	job_ids_string=$(join_by ',' ${job_ids[@]})

	read -r -d '' QUERY <<-EOF
		WITH hostname_query AS (
			SELECT job_id,
				metric_value as hostname
			FROM job_metric_text
			WHERE job_id IN ($job_ids_string)
				AND metric_name='HOSTNAME'
		),
		metric_num_query AS (
			SELECT job_id,
				SUM(CASE WHEN metric_name='runtime_seconds' THEN metric_value END) runtime_seconds,
				pg_size_pretty(SUM(CASE WHEN metric_name='memtotal' THEN metric_value END)) memtotal
			FROM job_metric_numeric
			WHERE job_id IN ($job_ids_string)
				AND metric_name IN ('runtime_seconds', 'memtotal')
			GROUP BY job_id
		)

		SELECT job.id,
			job.create_time,
			job.update_time,
			job.tool_id,
			job.state
			job.handler,
			hostname_query.hostname,
			metric_num_query.runtime_seconds,
			metric_num_query.memtotal
		FROM job
			FULL OUTER JOIN hostname_query ON hostname_query.job_id = job.id
			FULL OUTER JOIN metric_num_query ON metric_num_query.job_id = job.id
		WHERE job.id IN ($job_ids_string)
	EOF
}

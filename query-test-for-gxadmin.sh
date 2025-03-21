get_user_filter(){
	echo "(galaxy_user.email = '$1' or galaxy_user.username = '$1' or galaxy_user.id = CAST(REGEXP_REPLACE('$1', '.*\D+.*', '-1') AS INTEGER))"
}

local_query-jobs()  { ##? [--tool] [--destination] [--limit] [--states] [--user] [--terminal] [--nonterminal]: List jobs ordered by most recently updated
	handle_help "$@" <<-EOF
		Displays a list of jobs ordered from most recently updated, which can be filtered by states, destination_id,
		tool_id or user. By default up to 50 rows are returned which can be adjusted with the --limit or -l flag.

		$ gxadmin query jobs --destination=pulsar-nci-test
		  id   |     create_time     |     update_time     | user_id |  state  |                                           tool_id                                           |  handler  |         destination         | external_id
		-------+---------------------+---------------------+---------+---------+---------------------------------------------------------------------------------------------+-----------+-----------------------------+-------------
		 14701 | 2022-10-31 00:54:43 | 2022-10-31 00:55:02 |      16 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/bwa/bwa_mem/0.7.17.2                                   | handler_0 | pulsar-nci-test             | 14701
		 14700 | 2022-10-31 00:53:45 | 2022-10-31 00:54:04 |      16 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/fastqc/fastqc/0.71                                     | handler_0 | pulsar-nci-test             | 14700
		 14588 | 2022-10-19 10:45:42 | 2022-10-19 10:46:01 |      16 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/bwa/bwa_mem/0.7.17.2                                   | handler_2 | pulsar-nci-test             | 14588
		 14584 | 2022-10-19 10:45:12 | 2022-10-19 10:45:31 |      16 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/bwa/bwa_mem/0.7.17.2                                   | handler_2 | pulsar-nci-test             | 14584
		 14580 | 2022-10-19 10:44:43 | 2022-10-19 10:45:02 |      16 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/bwa/bwa_mem/0.7.17.2                                   | handler_2 | pulsar-nci-test             | 14580
			
		$ gxadmin query jobs -d=pulsar-nci-test -t=bionano
		  id   |     create_time     |     update_time     | user_id | state |                                        tool_id                                         |       handler       |         destination         | external_id
		-------+---------------------+---------------------+---------+-------+----------------------------------------------------------------------------------------+---------------------+-----------------------------+-------------
		 14085 | 2022-09-08 07:44:48 | 2022-09-08 08:21:58 |       3 | ok    | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_2           | pulsar-nci-test             | 14085
		 14080 | 2022-09-08 07:00:14 | 2022-09-08 07:44:31 |       3 | ok    | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_0           | pulsar-nci-test             | 14080
		 14076 | 2022-09-08 06:15:37 | 2022-09-08 06:59:59 |       3 | error | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_2           | pulsar-nci-test             | 14076
		 14071 | 2022-09-08 05:38:25 | 2022-09-08 06:15:22 |       3 | error | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_1           | pulsar-nci-test             | 14071
	EOF

	tool_id_substr=''
	limit=50

	echo $arg_tool

	[[ -n $arg_tool ]] && tool_id_substr=$arg_tool
	[[ -n $arg_destination ]] && destination_id_substr=$arg_destination
	[[ -n $arg_limit ]] && limit=$arg_limit
	[[ -n $arg_states ]] && states=$arg_states
	[[ -n $arg_terminal ]] && states="ok,deleted,error"
	[[ -n $arg_nonterminal ]] && states="new,queued,running"
	[[ -n $arg_nonterminal ]] && user_filter=" AND $(get_user_filter $arg_user)"


	# if (( $# > 0 )); then
	# 	for args in "$@"; do
	# 		if [ "${args:0:7}" = '--tool=' ]; then
	# 			tool_id_substr="${args:7}"
	# 		elif [ "${args:0:3}" = '-t=' ]; then
	# 			tool_id_substr="${args:3}"
	# 		elif [ "${args:0:8}" = '--limit=' ]; then
	# 			limit="${args:8}"
	# 		elif [ "${args:0:3}" = '-l=' ]; then
	# 			limit="${args:3}"
	# 		elif [ "${args:0:14}" = '--destination=' ]; then
	# 			destination_id_substr="${args:14}"
	# 		elif [ "${args:0:3}" = '-d=' ]; then
	# 			destination_id_substr="${args:3}"
	# 		elif [ "${args:0:9}" = '--states=' ]; then
	# 			states="${args:9}"
	# 		elif [ "${args:0:3}" = '-s=' ]; then
	# 			states="${args:3}"
	# 		elif [ "${args:0:7}" = '--user=' ]; then
	# 			user_filter=" AND $(get_user_filter ${args:7})"
	# 		elif [ "${args:0:3}" = '-u=' ]; then
	# 			user_filter=" AND $(get_user_filter ${args:3})"
	# 		elif [ "${args:0:10}" = '--terminal' ]; then
	# 			states="ok,deleted,error"
	# 		elif [ "${args:0:13}" = '--nonterminal' ]; then
	# 			states="new,queued,running"
	# 		fi
	# 	done
	# fi

	get_state_filter() {
		if [ "$states" ]; then
			states="'$(echo "$states" | sed "s/,/', '/g")'"
			echo "AND job.state IN (${states})"
		fi
	}

	get_destination_filter() {
		if [ ! -z "$destination_id_substr" ]; then
			echo "AND job.destination_id ~ '${destination_id_substr}'";
		fi
	}

	read -r -d '' QUERY <<-EOF
			SELECT
				job.id as job_id,
				job.create_time::timestamp(0) as create_time,
				job.update_time::timestamp(0) as update_time,
				job.user_id as user_id,
				job.state as state,
				job.tool_id as tool_id,
				job.handler as handler,
				job.destination_id as destination,
				job.job_runner_external_id as external_id
			FROM job
			LEFT OUTER JOIN
				galaxy_user ON job.user_id = galaxy_user.id
			WHERE job.tool_id ~ '$tool_id_substr' $(get_destination_filter) $(get_state_filter) $user_filter
			ORDER BY job.update_time desc
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

# get_user_filter(){
# 	echo "(galaxy_user.email = '$1' or galaxy_user.username = '$1')"
# }
# get_user_filter(){
# 	echo "(galaxy_user.email = '$1' or galaxy_user.username = '$1' or SELECT CASE WHEN '$1'~E'^\\d+$' THEN galaxy_user.id = CAST(<column> AS INTEGER) END"
# }


local_query-jobs-per-user() { ##? <user>: Number of jobs run by a specific user
	arg_user="$1"
	handle_help "$@" <<-EOF
		    $ gxadmin query jobs-per-user helena
		     count | user_id
		    -------+---------
		       999 |       1
		    (1 row)
	EOF

	user_filter=$(get_user_filter "$arg_user")

	read -r -d '' QUERY <<-EOF
			SELECT count(*), user_id
			FROM job
			WHERE user_id in (
				SELECT id
				FROM galaxy_user
				WHERE $user_filter
			)
			GROUP BY user_id
	EOF
}
local_query-jobs-edit() { ##? [--tool=] [--destination=] [--limit=50] [--states=<comma,sep,list>] [--user=] [--terminal] [--nonterminal] [--order-by-create-time]: List jobs ordered by most recently updated. = is required.
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
		
		    $ gxadmin query jobs --destination=pulsar-nci-test --tool=bionano
		      id   |     create_time     |     update_time     | user_id | state |                                        tool_id                                         |       handler       |         destination         | external_id
		    -------+---------------------+---------------------+---------+-------+----------------------------------------------------------------------------------------+---------------------+-----------------------------+-------------
		     14085 | 2022-09-08 07:44:48 | 2022-09-08 08:21:58 |       3 | ok    | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_2           | pulsar-nci-test             | 14085
		     14080 | 2022-09-08 07:00:14 | 2022-09-08 07:44:31 |       3 | ok    | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_0           | pulsar-nci-test             | 14080
		     14076 | 2022-09-08 06:15:37 | 2022-09-08 06:59:59 |       3 | error | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_2           | pulsar-nci-test             | 14076
		     14071 | 2022-09-08 05:38:25 | 2022-09-08 06:15:22 |       3 | error | toolshed.g2.bx.psu.edu/repos/bgruening/bionano_scaffold/bionano_scaffold/3.6.1+galaxy3 | handler_1           | pulsar-nci-test             | 14071
	EOF

	tool_id_substr="${arg_tool}"
	destination_id_substr="${arg_destination}"
	states="${arg_states}"

	if [[ -n "$arg_user" ]]; then
		user_filter=" AND $(get_user_filter "$arg_user")"
	fi
	if [[ -n "$arg_terminal" ]]; then
		states="ok,deleted,error"
	fi
	if [[ -n "$arg_nonterminal" ]]; then
		states="new,queued,running"
	fi
	# if [[ -n "$arg_nonterminal" ]]; then
	# 	states="new,queued,running"
	# fi

	state_filter=
	if [[ "$states" ]]; then
		states="'$(echo "$states" | sed "s/,/', '/g")'"
		state_filter="AND job.state IN (${states})"
	fi

	destination_filter=
	if [[ -n "$destination_id_substr" ]]; then
		destination_filter="AND job.destination_id ~ '${destination_id_substr}'";
	fi

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
			WHERE job.tool_id ~ '$tool_id_substr' ${destination_filter} ${state_filter} $user_filter
			ORDER BY job.create_time desc
			LIMIT $arg_limit
	EOF
}
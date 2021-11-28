local_query-queue() { ##? [--all] [--seconds] [--since-update]: Detailed overview of running and queued jobs
	# this is a copy of gxadmin query queue-detail with job destination info (cores/mem/partition) added and runner_id, count removed
	handle_help "$@" <<-EOF
			$ gxadmin local query-queue
			  state  |  id  | extid |                          tool_id                          | username | time_since_creation |       handler       | cores | mem  | partition | destination_id
			---------+------+-------+-----------------------------------------------------------+----------+---------------------+---------------------+-------+------+-----------+-----------------
			 running | 4385 | 4011  | upload1                                                   | cat      | 00:01:01.518932     | main.job-handlers.2 | 2     | 6144 |           | slurm
			 queued  | 4387 | 4012  | toolshed.g2.bx.psu.edu/repos/devteam/bwa/bwa_mem/0.7.17.2 | cat      | 00:00:24.377336     | main.job-handlers.2 | 1     | 3072 |           | slurm
			 queued  | 4388 | 4388  | toolshed.g2.bx.psu.edu/repos/devteam/bwa/bwa_mem/0.7.17.2 | cat      | 00:00:13.254505     | main.job-handlers.1 | 1     | 3072 |           | pulsar-nci-test
			 queued  | 4389 | 4013  | toolshed.g2.bx.psu.edu/repos/devteam/bwa/bwa_mem/0.7.17.2 | cat      | 00:00:01.834048     | main.job-handlers.2 | 1     | 3072 |           | slurm
	EOF

	fields="count=9"
	tags="state=0;id=1;extid=2;tool_id=3;username=4;handler=6;job_runner_name=7;destination_id=8"

	d=""
	nonpretty="("
	time_column="job.create_time"
	time_column_name="time_since_creation"

	if [[ -n "$arg_all" ]]; then
		d=", 'new'"
	fi
	if [[ -n "$arg_seconds" ]]; then
		fields="$fields;time_since_creation=5"
		nonpretty="EXTRACT(EPOCH FROM "
	fi
	if [[ -n "$arg_since_update" ]]; then
		time_column="job.update_time"
		time_column_name="time_since_update"
	fi

	username=$(gdpr_safe galaxy_user.username username "Anonymous User")

	read -r -d '' QUERY <<-EOF
		SELECT
			job.state,
			job.id,
			job.job_runner_external_id as extid,
			job.tool_id,
			$username,
			$nonpretty now() AT TIME ZONE 'UTC' - $time_column) as $time_column_name,
			job.handler,
			(REGEXP_MATCHES(encode(job.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as cores,
			(REGEXP_MATCHES(encode(job.destination_params, 'escape'), 'mem=(\d+)'))[1] as mem,
			(REGEXP_MATCHES(encode(job.destination_params, 'escape'), 'partition=(\d+)'))[1] as partition,
			COALESCE(job.destination_id, 'none') as destination_id
		FROM job
		FULL OUTER JOIN galaxy_user ON job.user_id = galaxy_user.id
		WHERE
			state in ('running', 'queued'$d)
		ORDER BY
			state desc,
			$time_column_name desc
	EOF
}
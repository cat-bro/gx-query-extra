local_query-queue() { ##? [--all] [--seconds] [--since-update]: Detailed overview of running and queued jobs
    # this is a rip off of gxadmin query queue-detail with job destination info (cores/mem)
	handle_help "$@" <<-EOF
		    $ gxadmin query queue-detail
		      state  |   id    |  extid  |                                 tool_id                                   | username | time_since_creation
		    ---------+---------+---------+---------------------------------------------------------------------------+----------+---------------------
		     running | 4360629 | 229333  | toolshed.g2.bx.psu.edu/repos/bgruening/infernal/infernal_cmsearch/1.1.2.0 | xxxx     | 5 days 11:00:00
		     running | 4362676 | 230237  | toolshed.g2.bx.psu.edu/repos/iuc/mothur_venn/mothur_venn/1.36.1.0         | xxxx     | 4 days 18:00:00
		     running | 4364499 | 231055  | toolshed.g2.bx.psu.edu/repos/iuc/mothur_venn/mothur_venn/1.36.1.0         | xxxx     | 4 days 05:00:00
		     running | 4366604 | 5183013 | toolshed.g2.bx.psu.edu/repos/iuc/dexseq/dexseq_count/1.24.0.0             | xxxx     | 3 days 20:00:00
		     running | 4366605 | 5183016 | toolshed.g2.bx.psu.edu/repos/iuc/dexseq/dexseq_count/1.24.0.0             | xxxx     | 3 days 20:00:00
		     queued  | 4350274 | 225743  | toolshed.g2.bx.psu.edu/repos/iuc/unicycler/unicycler/0.4.6.0              | xxxx     | 9 days 05:00:00
		     queued  | 4353435 | 227038  | toolshed.g2.bx.psu.edu/repos/iuc/trinity/trinity/2.8.3                    | xxxx     | 8 days 08:00:00
		     queued  | 4361914 | 229712  | toolshed.g2.bx.psu.edu/repos/iuc/unicycler/unicycler/0.4.6.0              | xxxx     | 5 days -01:00:00
		     queued  | 4361812 | 229696  | toolshed.g2.bx.psu.edu/repos/iuc/unicycler/unicycler/0.4.6.0              | xxxx     | 5 days -01:00:00
		     queued  | 4361939 | 229728  | toolshed.g2.bx.psu.edu/repos/nml/spades/spades/1.2                        | xxxx     | 4 days 21:00:00
		     queued  | 4361941 | 229731  | toolshed.g2.bx.psu.edu/repos/nml/spades/spades/1.2                        | xxxx     | 4 days 21:00:00
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
			job.job_runner_name,
            (REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'ntasks=(\d+)'))[1] as cores,
            (REGEXP_MATCHES(encode(j.destination_params, 'escape'), 'mem=(\d+)'))[1] as mem,
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
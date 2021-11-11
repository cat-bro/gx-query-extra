local_query-jobs-running-at-datetime() { ##? <datetime> datetime string
	datetime="$1"
	handle_help "$@" <<-EOF

    Find all jobs in queued, running or ok state that were created before and updated after a given datetime.  This was written with the aim of finding
    non-deleted jobs that may have two sets of data files due to the hierarchical object store path having changed while they were queued or running.

    $ gxadmin local query-jobs-running-at-datetime "2021-09-28 14:00"
     job_id  |          created           |          updated           | user_id | state |                                   tool_id                                   | destination_id
    ---------+----------------------------+----------------------------+---------+-------+-----------------------------------------------------------------------------+-----------------
     7396484 | 2021-09-28 13:59:25.91883  | 2021-09-28 15:09:09.148783 |   24601 | ok    | toolshed.g2.bx.psu.edu/repos/devteam/tophat2/tophat2/2.1.1                  | pulsar-mel3_mid
     7396483 | 2021-09-28 13:58:59.578761 | 2021-09-28 15:06:50.605129 |   24601 | ok    | toolshed.g2.bx.psu.edu/repos/devteam/tophat2/tophat2/2.1.1                  | slurm_1slot
     7396455 | 2021-09-28 13:27:11.979348 | 2021-09-28 14:01:13.616717 |    2468 | ok    | toolshed.g2.bx.psu.edu/repos/devteam/fastqc/fastqc/0.73+galaxy0             | pulsar-mel3_mid
     7396432 | 2021-09-28 12:59:47.650807 | 2021-09-28 14:49:57.488824 |    2468 | ok    | toolshed.g2.bx.psu.edu/repos/pjbriggs/trimmomatic/trimmomatic/0.36.6        | slurm_3slots
     7396349 | 2021-09-28 12:35:23.974676 | 2021-09-28 14:32:15.411004 |   21583 | ok    | toolshed.g2.bx.psu.edu/repos/iuc/unicycler/unicycler/0.4.8.0                | pulsar-mel3_mid
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
                j.update_time as updated,
				j.user_id as user_id,
				j.state as state,
				j.tool_id as tool_id,
                j.destination_id as destination_id
			FROM job j
            WHERE j.create_time < '$datetime'
			AND j.update_time > '$datetime'
			AND j.state in ('queued', 'running', 'ok', 'error')
			ORDER BY j.create_time desc
	EOF
}
local_query-jobs-by-object-store-id() { ## [object_store_ids]: Comma separated substrings of object store backend IDs, optional limit as second arg
	object_store_ids="$1"
	object_store_str=$(echo $object_store_ids | sed 's/,/\|/g')
	[ ! "$2" ] && limit="50" || limit="$2"
	handle_help "$@" <<-EOF

		See most recent jobs created with input data from a range of object store ids specified by a comma-separated string, such as data1,data2

			$ gxadmin local query-jobs-by-object-store-id aarnetNFS5 200
			 job_id  |          created           | user_id |  state  |                                         tool_id                                         |     destination
			---------+----------------------------+---------+---------+-----------------------------------------------------------------------------------------+----------------------
			 7479270 | 2024-02-21 04:53:58.874936 |   14000 | ok      | toolshed.g2.bx.psu.edu/repos/iuc/snippy/snippy/4.6.0+galaxy0                            | pulsar-mel3
			 7477098 | 2024-02-21 02:24:55.58023  |   20001 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/sam_to_bam/sam_to_bam/2.1.2                        | slurm
			 7477094 | 2024-02-21 02:24:55.184211 |   20001 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/bowtie_wrappers/bowtie_wrapper/1.2.0               | pulsar-QLD
			 7477027 | 2024-02-21 02:16:23.615611 |   20001 | ok      | toolshed.g2.bx.psu.edu/repos/devteam/sam_to_bam/sam_to_bam/2.1.2                        | slurm
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT DISTINCT
				j.id as job_id,
				j.create_time as created,
				j.update_time as updated,
				j.user_id,
				j.state as state,
				j.tool_id as tool_id,
				j.destination_id as destination
			FROM job j
				JOIN job_to_input_dataset jtid
					ON j.id = jtid.job_id
				JOIN history_dataset_association hda
					ON hda.id = jtid.dataset_id
				JOIN dataset d
					ON hda.dataset_id = d.id
			WHERE
				d.object_store_id ~ '$object_store_str'
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}
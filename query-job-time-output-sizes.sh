local_query-job-time-output-sizes() { ##? <tool> input tool substr,  # optional <limit>
	datetime="$1"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				d.id as dataset_id,
				j.create_time as created,
                j.update_time as updated,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
                d.total_size as dataset_size,
                j.destination_id as destination_id
			FROM job_to_output_dataset jtod, dataset d, job j, galaxy_user u, history_dataset_association hda
			WHERE j.user_id = u.id
            AND jtod.job_id = j.id
            AND j.create_time < '$datetime'
			AND j.update_time > '$datetime'
			AND jtod.dataset_id = hda.id
			AND hda.dataset_id = d.id
			AND j.state in ('queued', 'running', 'ok')
			ORDER BY j.create_time desc
	EOF
}

local_query-jobs-running-at-time() {
	datetime="$1"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
                j.update_time as updated,
				u.username,
				j.state as state,
				j.tool_id as tool_id,
                j.destination_id as destination_id
			FROM job j, galaxy_user u
			WHERE j.user_id = u.id
            AND j.create_time < '$datetime'
			AND j.update_time > '$datetime'
			AND j.state in ('queued', 'running', 'ok')
			ORDER BY j.create_time desc
	EOF
}

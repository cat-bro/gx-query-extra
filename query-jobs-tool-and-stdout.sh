local_query-jobs-tool-and-stdout() { ## input tool substr,  stderr substr, optional limit
    tool_substr="$1"
	tool_stdout_substr="$2"
    limit="$3"
	[ ! "$3" ] && limit="50" || limit="$3"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.id as job_id,
				j.create_time as created,
				(
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state in ('error', 'deleted', 'ok')) -
					(SELECT MIN(jsh.create_time) FROM job_state_history jsh
					WHERE jsh.job_id = j.id AND jsh.state = 'running')
				) as run_time,
				j.state as state,
				j.tool_id as tool_id,
				(
					SELECT
					pg_size_pretty(SUM(d.total_size))
					FROM dataset d, history_dataset_association hda, job_to_input_dataset jtid
					WHERE hda.dataset_id = d.id
					AND jtid.job_id = j.id
					AND hda.id = jtid.dataset_id
				) as sum_input_size,
				j.destination_id as destination
			FROM job j
			WHERE position('$tool_stdout_substr' in j.tool_stdout)>0
            AND position('$tool_substr' in j.tool_id)>0
			ORDER BY j.create_time desc
			LIMIT $limit
	EOF
}
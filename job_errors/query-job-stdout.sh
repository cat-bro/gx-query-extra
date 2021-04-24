local_query-job-stdout() { # <job_id>
	job_id="$1"

	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				j.job_stdout
            FROM
                job j
            WHERE
                j.id = $job_id
	EOF
}
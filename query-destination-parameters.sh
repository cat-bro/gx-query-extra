local_query-destination-parameters() {
	arg_id="$1"
	handle_help "$@" <<-EOF
	EOF

	read -r -d '' QUERY <<-EOF
			SELECT
				encode(j.destination_params, 'escape')
			FROM job j
			WHERE j.id = $arg_id
	EOF
}

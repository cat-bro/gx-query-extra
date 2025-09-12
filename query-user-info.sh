local_query-user-info() {
	handle_help "$@" <<-EOF

	EOF

	assert_count_ge $# 1 "No users specified"

	if [[ "$1" == "-" ]]; then
		# read users from stdin
		users=$(cat | paste -s -d' ')
	else
		# read from $@
		users=$*;
	fi

	# shellcheck disable=SC2068
	users_string=$(join_by ',' ${users[@]})
    echo $users_string

	read -r -d '' QUERY <<-EOF
		SELECT
			username, id, email, create_time AT TIME ZONE 'UTC' as create_time, active, deleted, purged, pg_size_pretty(disk_usage) as disk_usage
		FROM
			galaxy_user
		WHERE
			(galaxy_user.email in ('$users_string') or galaxy_user.username in ('$users_string') or galaxy_user.id::text in ('$users_string'))
	EOF
}
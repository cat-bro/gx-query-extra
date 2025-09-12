local_query-user-info() { ## <-|user [user [...]]> : Retrieve information about users given some user identifiers (id, username or email)
	handle_help "$@" <<-EOF
	$gxadmin local query-user-info roosta arthur-dent
	 username    |  id  |               email           |          create_time          | active | deleted | purged | disk_usage
	-------------+------+-------------------------------+-------------------------------+--------+---------+--------+------------
	 roosta      |  409 | roosta2000@unimelb.edu.au     | 2016-08-22 06:16:17.377211+00 | t      | f       | f      | 102 GB
	 authur-dent | 5948 | arthur.dent725@unimelb.edu.au | 2019-12-08 22:59:10.536365+00 | t      | f       | f      | 569 GB
	EOF

	assert_count_ge $# 1 "No users specified"

	if [[ "$1" == "-" ]]; then
		# read jobs from stdin
		users=$(cat | paste -s -d' ')
	else
		# read from $@
		users=$*;
	fi

	# shellcheck disable=SC2068
	users_string=$(join_by "','" ${users[@]})

	read -r -d '' QUERY <<-EOF
		SELECT
			id, username, email, create_time AT TIME ZONE 'UTC' as create_time, active, deleted, purged, pg_size_pretty(disk_usage) as disk_usage
		FROM
			galaxy_user
		WHERE
			(galaxy_user.email in ('$users_string') or galaxy_user.username in ('$users_string') or galaxy_user.id::text in ('$users_string'))
	EOF
}
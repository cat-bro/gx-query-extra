local_query-user-info() {
	handle_help "$@" <<-EOF

	EOF

	read -r -d '' QUERY <<-EOF
		SELECT
			username, id, email, create_time AT TIME ZONE 'UTC' as create_time, external, deleted, purged, active, pg_size_pretty(disk_usage)
		FROM
			galaxy_user
		WHERE
			(galaxy_user.email = '$1' or galaxy_user.username = '$1' or galaxy_user.id = CAST(REGEXP_REPLACE(COALESCE('$1','0'), '[^0-9]+', '0', 'g') AS INTEGER))
	EOF
}
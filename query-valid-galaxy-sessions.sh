local_query-valid-galaxy-sessions(){
	handle_help "$@" <<-EOF

  TODO: help text
EOF

		read -r -d '' QUERY <<-EOF
			SELECT
				galaxy_session.id as id,
				galaxy_session.create_time as create_time,
				user_id,
				email,
				remote_host,
				remote_addr,
				referer,
				is_valid,
				last_action
			FROM galaxy_session
			WHERE galaxy_session.is_valid = 't'
			ORDER BY galaxy_session.create_time DESC
EOF
}

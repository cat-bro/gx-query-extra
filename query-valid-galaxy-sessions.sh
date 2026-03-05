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
			LEFT JOIN galaxy_user AS galaxy_session_user
			ON galaxy_session.user_id = galaxy_session_user.id
			WHERE galaxy_session.is_valid = 't'
			ORDER BY galaxy_session.create_time DESC
EOF
}

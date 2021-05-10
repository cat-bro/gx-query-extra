HERE=${BASH_SOURCE%/*}

source $HERE/functions/gdpr_safe.sh

local_query-training-members() { ##? <tr_id>: List users in a specific training
	handle_help "$@" <<-EOF
		    $ gxadmin query training-members hts2018
		          username      |       joined
		    --------------------+---------------------
		     helena-rasche      | 2018-09-21 21:42:01
	EOF

	# Remove training- if they used it.
	ww=$(echo "$arg_tr_id" | sed 's/^training-//g')
	username=$(gdpr_safe galaxy_user.username username)

	read -r -d '' QUERY <<-EOF
			SELECT DISTINCT ON (COALESCE(galaxy_user.username::text, '__UNKNOWN__') as username)
				username,
				date_trunc('second', user_group_association.create_time AT TIME ZONE 'UTC') as joined
			FROM galaxy_user, user_group_association, galaxy_group
			WHERE galaxy_group.name = 'training-$ww'
				AND galaxy_group.id = user_group_association.group_id
				AND user_group_association.user_id = galaxy_user.id
	EOF
}

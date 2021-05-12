#select distinct u.username, g.name, g.create_time from galaxy_user u, role r, galaxy_group g, group_role_association gra, user_group_association uga where gra.group_id = g.id and gra.role_id = r.id and uga.group_id = g.id and uga.user_id = u.id and position('training' in g.name)>0 and g.deleted = 'f'  and r.deleted = 'f' order by g.create_time;

local_query-training-members2() { ##? <tr_id>: List users in a specific training
    arg_tr_id="$1" # not necessary in normal gxadmin, just local queries
	handle_help "$@" <<-EOF
		    $ gxadmin query training-members hts2018
		          username      |       joined
		    --------------------+---------------------
		     helena-rasche      | 2018-09-21 21:42:01
	EOF

	# Remove training- if they used it.
	ww=$(echo "$arg_tr_id" | sed 's/^training-//g')
	username=$(gdpr_safe galaxy_user.username username)
    echo $ww

	read -r -d '' QUERY <<-EOF
			SELECT
				galaxy_user.username,
                galaxy_user.id,
				date_trunc('second', user_group_association.create_time AT TIME ZONE 'UTC') as joined
			FROM galaxy_user, user_group_association, galaxy_group, role, group_role_association
			WHERE galaxy_group.name = 'training-$ww'
				AND galaxy_group.id = user_group_association.group_id
				AND user_group_association.user_id = galaxy_user.id
                AND group_role_association.group_id = galaxy_group.id
                AND group_role_association.role_id = role.id
	EOF
}


#select distinct u.username, g.name, g.create_time from galaxy_user u, role r, galaxy_group g, group_role_association gra, user_group_association uga where gra.group_id = g.id and gra.role_id = r.id and uga.group_id = g.id and uga.user_id = u.id and position('training' in g.name)>0 and g.deleted = 'f'  and r.deleted = 'f' order by g.create_time;

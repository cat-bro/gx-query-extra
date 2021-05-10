gdpr_safe() {
	local coalesce_to
	if (( $# > 2 )); then
		coalesce_to="$3"
	else
		coalesce_to="__UNKNOWN__"
	fi

	if [ -z "$GDPR_MODE" ]; then
		echo "COALESCE($1::text, '$coalesce_to') as $2"
	else
		# Try and be privacy respecting while generating numbers that can allow
		# linking data across tables if need be?
		echo "substring(md5(COALESCE($1::text, '$coalesce_to') || now()::date || '$GDPR_MODE'), 0, 12) as ${2:-$1}"
	fi
}
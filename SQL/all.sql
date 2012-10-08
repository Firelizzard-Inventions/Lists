CREATE VIEW IF NOT EXISTS _t_all
AS
	SELECT	group_id AS id,
			group_name AS name,
			'group' AS type,
			parent,
			1 AS is_primary
		FROM _t_group
UNION
	SELECT	list_id AS id,
			list_name as name,
			'list' AS type,
			parent,
			is_primary
		FROM _t_list
;
CREATE TABLE IF NOT EXISTS _t_list (
	list_id INTEGER PRIMARY KEY AUTOINCREMENT,
	list_name TEXT NOT NULL,
	parent NUMBER,
	list_table TEXT NOT NULL,
	preferences CLOB,
	CONSTRAINT _tl_parent_fk
		FOREIGN KEY (parent)
		REFERENCES _t_group(group_id),
	CONSTRAINT _tl_table_fk
		FOREIGN KEY (list_table)
		REFERENCES sqlite_master(name)
);
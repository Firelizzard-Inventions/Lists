CREATE TABLE IF NOT EXISTS _t_link (
	link_id INTEGER PRIMARY KEY AUTOINCREMENT,
	list_id INTEGER NOT NULL,
	table_name TEXT NOT NULL,
	CONSTRAINT _tl_list_fk
		FOREIGN KEY (list_id)
		REFERENCES _t_list(list_id),
	CONSTRAINT _tl_table_fk
		FOREIGN KEY (table_name)
		REFERENCES sqlite_master(name)
);
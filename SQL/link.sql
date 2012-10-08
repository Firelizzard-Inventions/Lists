CREATE TABLE IF NOT EXISTS _t_link (
	list_id INTEGER NOT NULL,
	table_name TEXT NOT NULL,
	CONSTRAINT _tk_pk
		PRIMARY KEY (list_id, table_name),
	CONSTRAINT _tl_table_fk
		FOREIGN KEY (table_name)
		REFERENCES sqlite_master(name)
);
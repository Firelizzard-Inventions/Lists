CREATE TABLE IF NOT EXISTS _t_group (
	group_id INTEGER PRIMARY KEY AUTOINCREMENT,
	group_name TEXT NOT NULL,
	parent NUMBER,
	preferences CLOB,
	CONSTRAINT _tg_parent_fk
		FOREIGN KEY (parent)
		REFERENCES _t_group(group_id)
);
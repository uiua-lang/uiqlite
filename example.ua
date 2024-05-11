# Experimental!
Sqlite ~ "lib"

Sqlite~Open "test.db"
Sqlite~Exec ⊙. $ CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT);
Sqlite~Exec ⊙. $ INSERT INTO test (name) VALUES ("Dave");
Sqlite~Prepare ⊙. $ SELECT name FROM test;
⍢(⟜(&p Sqlite~ColumnText 0))(Sqlite~Step)
Sqlite~Finalize
Sqlite~Close

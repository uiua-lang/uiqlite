# Experimental!
Sql ~ "lib"

Sql~Open "test.db"
Sql~Exec "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT);" .
Sql~Exec "INSERT INTO test (name) VALUES (\"Dave\");" .
Sql~Close

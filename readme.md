# Uiqlite
Sqlite3 bindings for Uiua

**This is a work in progress and is not usable for much yet.**

# Example

```uiua
# Experimental!
Sql ~ "git: github.com/uiua-lang/uiqlite"

Sql~Open "test.db"
Sql~Exec "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT);" .
Sql~Exec "INSERT INTO test (name) VALUES (\"Dave\");" .
Sql~Close
```

To run the example (which is in `example.ua`), you must provide the path to the sqlite3 library:
```
uiua run example.ua /path/to/libsqlite3.so
```

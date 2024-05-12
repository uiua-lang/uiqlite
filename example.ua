# Experimental!
Sqlite ~ "lib"

Sqlite~Open "test.db"

$ CREATE TABLE IF NOT EXISTS test (
$   id INTEGER PRIMARY KEY,
$   blob BLOB
$ );
Sqlite~Exec ⊙.

⍥(
  $ INSERT INTO test (blob) VALUES (?);
  Sqlite~Prepare ⊙.
  ⟜(Sqlite~BindBlob 1 [1 2 3 4 5])
  Sqlite~ExecuteInsert
) 5

Sqlite~Prepare ⊙. $ SELECT blob FROM test;
Sqlite~QueryValues
⊙Sqlite~Close

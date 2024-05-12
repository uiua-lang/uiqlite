# Experimental!
Sqlite ~ "lib"

Sqlite~Open ":memory:"

$ CREATE TABLE IF NOT EXISTS test (
$   id INTEGER PRIMARY KEY,
$   int INT
$ );
Sqlite~Exec ⊙.

⍥(
  $ INSERT INTO test (int) VALUES (:named);
  Sqlite~Prepare ⊙.
  Sqlite~BindNamed ":named" ⁅×69⚂ .
  Sqlite~ExecuteInsert
) 5

Sqlite~Prepare ⊙. $ SELECT * FROM test;
Sqlite~QueryValues
⊙Sqlite~Close

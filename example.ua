# Experimental!
Sqlite ~ "lib"

Sqlite~Open ":memory:"

$ CREATE TABLE IF NOT EXISTS test (
$   id INTEGER PRIMARY KEY,
$   int1 INT,
$   int2 INT,
$   int3 INT
$ );
Sqlite~Exec ⊙.

⍥(
  $ INSERT INTO test (int1, int2, int3) VALUES (?, ?, ?);
  Sqlite~Prepare ⊙.
  Sqlite~BindValues {1 2 3} .
  Sqlite~ExecuteInsert
) 5

Sqlite~Prepare ⊙. $ SELECT * FROM test;
Sqlite~QueryValues
⊙Sqlite~Close

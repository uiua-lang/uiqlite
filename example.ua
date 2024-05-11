# Experimental!
Sqlite ~ "lib"

Sqlite~Open ":memory:"

$ CREATE TABLE IF NOT EXISTS test (
$   id INTEGER PRIMARY KEY,
$   text TEXT,
$   blob BLOB,
$   float FLOAT,
$   int INT,
$   nullable TEXT nuul
$ );
Sqlite~Exec ⊙.

$ INSERT INTO test (text, blob, float, int, nullable) VALUES (
$   "Dave",
$   X'0102030405060708090a0b0c0d0e0f',
$   42.42,
$   123,
$   NULL
$ );
Sqlite~Exec ⊙.
Sqlite~Prepare ⊙. $ SELECT text, float, int, nullable FROM test;
⍢(
  ⟜(&p Sqlite~ColumnValue 0)
  ⟜(&p Sqlite~ColumnValue 1)
  ⟜(&p Sqlite~ColumnValue 2)
  ⟜(&p Sqlite~ColumnValue 3)
)(Sqlite~Step)
Sqlite~Finalize
Sqlite~Close

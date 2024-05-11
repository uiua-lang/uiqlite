# Experimental!
Sqlite ~ "lib"

Sqlite~Open ":memory:"

$ CREATE TABLE IF NOT EXISTS test (
$   id INTEGER PRIMARY KEY,
$   text TEXT,
$   float FLOAT,
$   int INT,
$   nullable TEXT nuul
$ );
Sqlite~Exec ⊙.

$ INSERT INTO test (text, float, int, nullable) VALUES (
$   "Dave",
$   42.42,
$   123,
$   NULL
$ );
Sqlite~Exec ⊙.

$ INSERT INTO test (text, float, int, nullable) VALUES (
$   "Steve",
$   32.34,
$   321,
$   NULL
$ );
Sqlite~Exec ⊙.

Sqlite~Prepare ⊙. $ SELECT text, float, int, nullable FROM test;
Sqlite~QueryValues

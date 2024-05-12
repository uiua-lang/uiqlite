# Experimental!
Sqlite ~ "lib"

Sqlite~Open ":memory:"

$ CREATE TABLE IF NOT EXISTS test (
$   id INTEGER PRIMARY KEY,
$   int1 INT,
$   int2 FLOAT,
$   int3 INT NULL
$ );
Sqlite~Exec ⊙.

⍥(
  $ INSERT INTO test (int1, int2, int3) VALUES (:int1, :int2, :int3);
  .Sqlite~Prepare ⊙.
  {727 42.69 NaN}
  {":int1" ":int2" ":int3"}
  map
  Sqlite~BindNamedMap
  Sqlite~ExecuteInsert
) 5

Sqlite~Prepare ⊙. $ SELECT * FROM test;
Sqlite~QueryValues
⊙Sqlite~Close

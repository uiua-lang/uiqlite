# Experimental!
Sqlite ~ "lib"

Sqlite~Open ":memory:"

$ CREATE TABLE IF NOT EXISTS test (
$   id INTEGER PRIMARY KEY,
$   float FLOAT,
$   int INT,
$   nullable TEXT NULL
$ );
Sqlite~Exec ⊙.

⍥(
  $ INSERT INTO test (float, int, nullable) VALUES (?,?,?);
  Sqlite~Prepare ⊙.
  ⟜(Sqlite~BindFloat 1 ÷1000⁅×1000⚂)
  ⟜(Sqlite~BindInt 2 ⌈×10⚂)
  ⟜(Sqlite~BindNull 3)
  Sqlite~ExecuteInsert
) 5

Sqlite~Prepare ⊙. $ SELECT float, int, nullable FROM test;
Sqlite~QueryValues
⊙Sqlite~Close

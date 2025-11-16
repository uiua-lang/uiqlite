# Experimental!
Sql ~ "lib"

# Test if the base type inference functions are working as expected
{NULL NaN 42 3.14 "hello" [23 34 45]}
⍉≡◇(Sql!⊃[IsNull|IsInt|IsFloat|IsText|IsBlob])
≍[1_1_0_0_0_0
  0_0_1_0_0_0
  0_0_0_1_0_0
  0_0_0_0_1_0
  ∞_0_0_0_0_1]
# FIXME: the infinity here is a bug with inconsistant NULL checking
⍤"The functions to check the type of a value are not acting as expected"

# Test if the type inference function is working as expected
{NaN 42 3.14 "hello" [23 34 45]}
≡◇Sql!InferType
≍[0 1 2 3 4]
⍤"The function to infer value type is not working as expected"

# If the given test case raises an error, return 0, otherwise return 1.
# Success ? TestCase
Try! ← ⍣(1^0|0)

# Database connection test
Try!(Sql~Close Sql~Open ":memory:")
⍤"Opening and closing an in-memory database failed"

# Exec test
Try!(
  Sql~Open ":memory:"
  $ CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT);
  $ INSERT INTO test (name) VALUES ("ekgame"), ("kaikalii"), ("JoaoFelipe3");
  Sql~Close ⊸Sql~Exec
)
⍤"Creating and inserting into a table failed"

# Prepared statement test macro.
# ? PreparedStatementString CreateTableStatement
TestPrepared! ← (
  ⊙⊙(Sql~Open ":memory:")
  ⊙(⊸Sql~Exec) # Expects a string to create a table
  ⊸(
    Sql~Prepare # Expects a string for prepared statement
    ⊸(^0)
    Sql~Finalize
  )
  Sql~Close
)

# Bind int test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num INTEGER);"
  "INSERT INTO test (num) VALUES (?);"
  TestPrepared!(°0 Sql~Step ⊸Sql~BindInt 67 1)
)
⍤"Binding int failed"

# Bind float test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num FLOAT);"
  "INSERT INTO test (num) VALUES (?);"
  TestPrepared!(°0 Sql~Step ⊸Sql~BindFloat 800.85 1)
)
⍤"Binding float failed"

# Bind null test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num INTEGER NULL);"
  "INSERT INTO test (num) VALUES (?);"
  TestPrepared!(°0 Sql~Step ⊸Sql~BindNull 1)
)
⍤"Binding null failed"

# Bind text test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, val VARCHAR(64));"
  "INSERT INTO test (val) VALUES (?);"
  TestPrepared!(°0 Sql~Step ⊸Sql~BindText "Hello world" 1)
)
⍤"Binding text failed"

# Bind blob test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, val BLOB);"
  "INSERT INTO test (val) VALUES (?);"
  TestPrepared!(°0 Sql~Step ⊸Sql~BindBlob [1 2 3 255] 1)
)
⍤"Binding blob failed"

# Bind arbitrary value test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num1 INTEGER, num2 FLOAT, text VARCHAR(64), blob BLOB, nullval INTEGER NULL);"
  "INSERT INTO test (num1, num2, text, blob, nullval) VALUES (?, ?, ?, ?, ?);"
  TestPrepared!(°0 Sql~Step ⊸Sql~BindValues {67 800.85 "Hello world" [1 2 3 255] NULL})
)
⍤"Binding arbitrary values failed"

# Bind named parameter test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num1 INTEGER, num2 INTEGER);"
  "INSERT INTO test (num1, num2) VALUES (:num1, :num2);"
  TestPrepared!(
    ⊸Sql~BindNamedValue 69 ":num1"
    ⊸Sql~BindNamedValue 420 ":num2"
    °0 ⊸Try!Sql~BindNamedValue 67 ":nonexistant"
    °0 Sql~Step
  )
)
⍤"Binding named arguments failed"

# Bind named value map test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num1 INTEGER, num2 INTEGER);"
  "INSERT INTO test (num1, num2) VALUES (:num1, :num2);"
  TestPrepared!(
    ⊸Sql~BindNamedValueMap map {":num1" ":num2"} {420 67}
    °0 Sql~Step
  )
)
⍤"Binding map failed"

# Column count test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num1 INTEGER, num2 INTEGER);"
  "SELECT num1, num2 FROM test;"
  TestPrepared!(°2 Sql~ColumnCount °0 ⊸Sql~Step)
)
⍤"Column count failed"

# Column name test
Try!(
  "CREATE TABLE test (id INTEGER PRIMARY KEY, num1 INTEGER, num2 INTEGER);"
  "SELECT num1, num2 as custom_name FROM test;"
  TestPrepared!(
    °0 ⊸Sql~Step
    °"num1" ⊸Sql~ColumnName 0
    °"custom_name" Sql~ColumnName 1
  )
)
⍤"Column name failed"

# Column type test
Try!(
  $ CREATE TABLE test (num1 INTEGER, num2 FLOAT, text VARCHAR(64), blob BLOB, nullval INTEGER NULL);
  $ INSERT INTO test (num1, num2, text, blob, nullval) VALUES (42, 3.14, "ekgame", X'010203', NULL);
  "SELECT num1, num2, text, blob, nullval FROM test;"
  TestPrepared!(
    °1 ⊸Sql~Step
    °Sql~Const~Integer ⊸Sql~ColumnType 0
    °Sql~Const~Float ⊸Sql~ColumnType 1
    °Sql~Const~Text ⊸Sql~ColumnType 2
    °Sql~Const~Blob ⊸Sql~ColumnType 3
    °Sql~Const~Null Sql~ColumnType 4
  )
)
⍤"Column type failed"

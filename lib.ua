# Experimental!

GetLibraryPath ← memo(
  Os ← ⍣(
    ⊸°"linux" os
  | "win"°"windows" os
  | ⊸°"macos" os
  )

  Arch ← ⍣(
    ⊸°"x86" arch
  | ⊸°"x86_64" arch
  )

  $"bin/sqlite3-_-_._" Os Arch dllext
  /($"___" ⊙pathsep) {"." ThisFileDir ∘}
  ⊸(⍤"Sqlite3 library artifact is not available for this platform."&fe)
)

# Track Caller!
Lib ↚ &ffi ⊂□GetLibraryPath

# Track Caller!
Call ↚ Lib ⊂⊟∩□

┌─╴Const
  Ok   ← 0
  Row  ← 100
  Done ← 101

  Integer ← 1
  Float   ← 2
  Text    ← 3
  Blob    ← 4
  Null    ← 5

  Static    ← 0
  Transient ← ¯1
└─╴

┌─╴FfiType
  DatabaseHandle  ← "void**"
  StatementHandle ← "void**"
  String          ← "char*"
└─╴

~SqliteConnection {DatabaseHandle}
~SqliteStatement {StatementHandle SqliteConnection}

# Get the error message from the last failed SQLite operation.
# String ? SqliteConnection
Err ← (
  # https://www.sqlite.org/c3ref/errcode.html
  # const char *sqlite3_errmsg(sqlite3*);
  {SqliteConnection~DatabaseHandle}
  Call FfiType~String "sqlite3_errmsg" FfiType!{DatabaseHandle}
)

# Open a database connection.
# SqliteConnection ? String
Open ← (
  # https://www.sqlite.org/c3ref/open.html
  # int sqlite3_open(const char *filename, sqlite3 **ppDb);
  ⟜(
    ⊃{∘|0}
    Call "int" "sqlite3_open" FfiType!{String ($"out _" DatabaseHandle)}
    ≍Const~Ok °{⊙∘}
  )
  ⍤ $"Failed to open database: _"
  SqliteConnection
)

# Close the database connection.
# ? SqliteConnection
Close ← (
  # https://www.sqlite.org/c3ref/close.html
  # int sqlite3_close(sqlite3*);
  ⊸(
    {SqliteConnection~DatabaseHandle}
    Call "int" "sqlite3_close" FfiType!{DatabaseHandle}
  )
  ⨬(˙⍤$"Failed to close database: _" Err|◌)≍Const~Ok
)

# Execute a raw SQL statement.
# ? String SqliteConnection
Exec ← (
  # https://www.sqlite.org/c3ref/exec.html
  # int sqlite3_exec(sqlite3*, const char *sql, int (*callback)(void*,int,char**,char**), void *, char **errmsg);
  ⊸(
    ⊃{SqliteConnection~DatabaseHandle ⋅∘|∘|0 0 ""}
    Call "int" "sqlite3_exec" FfiType!{DatabaseHandle String "void*" "void*" String}
  )
  ⨬(˙⍤$"Failed to exec: _" Err|◌)≍Const~Ok
)

# Prepare a SQL statement for execution.
# SqliteStatement ? String SqliteConnection
Prepare ← (
  # https://www.sqlite.org/c3ref/prepare.html
  # int sqlite3_prepare_v2(sqlite3 *db, const char *zSql, int nByte, sqlite3_stmt **ppStmt, const char **pzTail);
  ⊸(⊃{⋅SqliteConnection~DatabaseHandle|∘|¯1 0 ""}
    Call "int" "sqlite3_prepare_v2" FfiType!{DatabaseHandle String "int" ($"out _" StatementHandle) "char*"}
    °{⊙∘}
  )
  ⊃(∘|⋅⋅∘|⋅∘|⋅⋅∘)
  ⨬(˙⍤$"Failed to exec: _" Err|◌)≍Const~Ok
  SqliteStatement
)

# Evaluate a prepared statement.
# Returns 1 if there are more rows to fetch, 0 otherwise.
# HasMoreRows ? SqliteStatement
Step ← (
  # https://www.sqlite.org/c3ref/step.html
  # int sqlite3_step(sqlite3_stmt*);
  ⊸(
    {SqliteStatement~StatementHandle}
    Call "int" "sqlite3_step" FfiType!{StatementHandle}
  )
  ⊙(SqliteConnection~DatabaseHandle SqliteStatement~SqliteConnection)
  ⍣(1◌°Const~Row
  | 0◌°Const~Done
  | ˙⍤$"Failed to step the statement: _" Err
  )
)

# Delete a prepared statement.
# ? SqliteStatement
Finalize ← (
  # https://www.sqlite.org/c3ref/finalize.html
  # int sqlite3_finalize(sqlite3_stmt *pStmt);
  ⊸(
    {SqliteStatement~StatementHandle}
    Call "int" "sqlite3_finalize" FfiType!{StatementHandle}
  )
  ⊙(SqliteConnection~DatabaseHandle SqliteStatement~SqliteConnection)
  ⨬(˙⍤$"Failed to finalize statement: _" Err|◌)≍Const~Ok
)

BindBlob ← (
  # https://www.sqlite.org/c3ref/bind_blob.html
  # int sqlite3_bind_blob(sqlite3_stmt*, int index, const void *value, int numBytes, void(*)(void*));
  ⊸(
    ⊃{⋅⋅SqliteStatement~StatementHandle|⋅∘|∘|⧻|Const~Transient}
    Call "int" "sqlite3_bind_blob" FfiType!{StatementHandle "int" "byte*" "int" "void*"}
  )
  ⊙(SqliteConnection~DatabaseHandle SqliteStatement~SqliteConnection)
  ⨬(˙⍤$"Failed to bind blob: _" Err|◌)≍Const~Ok
)

# Bind an integer value to a prepared statement.
# ? Value Position SqliteStatement
BindInt ← (
  # https://www.sqlite.org/c3ref/bind_blob.html
  # int sqlite3_bind_int(sqlite3_stmt*, int index, int value);
  ⊸(
    ⊃{⋅⋅SqliteStatement~StatementHandle|⋅∘|∘}
    Call "int" "sqlite3_bind_int" FfiType!{StatementHandle "int" "int"}
  )
  ⊙(SqliteConnection~DatabaseHandle SqliteStatement~SqliteConnection)
  ⨬(˙⍤$"Failed to bind int: _" Err|◌)≍Const~Ok
)

# Bind a floating point value to a prepared statement.
# ? Value Position SqliteStatement
BindFloat ← (
  # https://www.sqlite.org/c3ref/bind_blob.html
  # int sqlite3_bind_double(sqlite3_stmt*, int index, double value);
  ⊸(
    ⊃{⋅⋅SqliteStatement~StatementHandle|⋅∘|∘}
    Call "int" "sqlite3_bind_double" FfiType!{StatementHandle "int" "double"}
  )
  ⊙(SqliteConnection~DatabaseHandle SqliteStatement~SqliteConnection)
  ⨬(˙⍤$"Failed to bind float: _" Err|◌)≍Const~Ok
)

# Bind a NULL value to a prepared statement.
# ? Position SqliteStatement
BindNull ← (
  # https://www.sqlite.org/c3ref/bind_blob.html
  # int sqlite3_bind_null(sqlite3_stmt*, int index);
  ⊸(
    ⊃{⋅SqliteStatement~StatementHandle|∘}
    Call "int" "sqlite3_bind_null" FfiType!{StatementHandle "int"}
  )
  ⊙(SqliteConnection~DatabaseHandle SqliteStatement~SqliteConnection)
  ⨬(˙⍤$"Failed to bind null: _" Err|◌)≍Const~Ok
)

# Bind a text value to a prepared statement.
# ? Value Position SqliteStatement
BindText ← (
  # https://www.sqlite.org/c3ref/bind_blob.html
  # https://www.sqlite.org/c3ref/c_static.html
  # int sqlite3_bind_text(sqlite3_stmt*, int index, const char *value, int numBytes, void(*)(void*));
  ⊸(
    ⊃{⋅⋅SqliteStatement~StatementHandle|⋅∘|∘|⧻utf₈|Const~Transient}
    Call "int" "sqlite3_bind_text" FfiType!{StatementHandle "int" String "int" "void*"}
  )
  ⊙(SqliteConnection~DatabaseHandle SqliteStatement~SqliteConnection)
  ⨬(˙⍤$"Failed to bind text: _" Err|◌)≍Const~Ok
)

┌─╴InferredType
  |Null
  |Int
  |Float
  |Text
  |Blob
└─╴

IsNull  ← ⍣(⊸°1≍NaN|⊸°1≍NULL|0)
IsInt   ← ⍣(≍⟜⁅ ⊸(°0≍NaN) ⊸(°0type) ⊸(°1≍[]△)|0)
IsFloat ← ⍣(¬≍⟜⁅ ⊸(°0type) ⊸(°1≍[]△)|0)
IsText  ← ⍣(=1type ⊸(°1⧻△)|0)
IsBlob  ← ⍣(/↧≤255 ⊸(°0type) ⊸(°1⧻△)|0)
InferType ← ⍣(
  ⊢⊚⊃[IsNull|IsInt|IsFloat|IsText|IsBlob]
  ˜⊡InferredType![Null Int Float Text Blob]
| ˙⍤"Invalid value"◌)

# Bind an arbitrary value to a prepared statement.
# ? Value Position SqliteStatement
BindValue ← (
  ⊸InferType
  InferredType!⍣(
    ⍩BindNull◌ °Null
  | ⍩BindInt °Int
  | ⍩BindFloat °Float
  | ⍩BindText °Text
  | ⍩BindBlob °Blob
  | ˙⍤"Unsupported bind value type: _"◌
  )
)

# Bind an array of values to a prepared statement.
# ? Values SqliteStatement
BindValues ← ⍚BindValue ⟜(+1⇡⧻) ⊙¤

# Get the index of a named parameter in a prepared statement.
# Index ? ParameterName:String SqliteStatement
BindParameterIndex ← (
  # https://www.sqlite.org/c3ref/bind_parameter_index.html
  # int sqlite3_bind_parameter_index(sqlite3_stmt*, const char *zName);
  ⤚(
    ⊃{⋅SqliteStatement~StatementHandle|∘}
    Call "int" "sqlite3_bind_parameter_index" FfiType!{StatementHandle String}
  )
  ⍣(⍩˙⍤ $"Named parameter not found: _" ⊙0 °0|⊙◌)
)

# Bind a value to a named parameter in a prepared statement.
# ? Value ParameterName:String SqliteStatement
BindNamedValue ← BindValue⊸⊙BindParameterIndex

# Bind a map of named parameters to a prepared statement.
# ? Map:String→Value SqliteStatement
BindNamedValueMap ← ⍚BindNamedValue ˜∘ °map ⊙¤

# Get the number of columns in the result set of a prepared statement.
# ColumnCount ? SqliteStatement
ColumnCount ← (
  # https://www.sqlite.org/c3ref/column_count.html
  # int sqlite3_column_count(sqlite3_stmt *pStmt);
  {SqliteStatement~StatementHandle}
  Call "int" "sqlite3_column_count" FfiType!{StatementHandle}
)

# Get the name of a column given an index in the result set of a prepared statement.
# String ? ColumnIndex:Int SqliteStatement
ColumnName ← (
  # https://www.sqlite.org/c3ref/column_name.html
  # const char *sqlite3_column_name(sqlite3_stmt*, int N);
  ⊃{⋅SqliteStatement~StatementHandle|∘}
  Call FfiType!String "sqlite3_column_name" FfiType!{StatementHandle "int"}
)

# Get the names of all columns in the result set of a prepared statement.
# ColumnNames ? SqliteStatement
ColumnNames ← (
  ⊃(⇡ColumnCount|¤)
  ≡(□ColumnName)
)

# Get the type of a column given an index in the result set of a prepared statement.
# The result is one of: Const\~Integer, Const\~Float, Const\~Text, Const\~Blob, Const\~Null.
# Int ? ColumnIndex:Int SqliteStatement
ColumnType ← (
  # https://www.sqlite.org/c3ref/column_blob.html
  # int sqlite3_column_type(sqlite3_stmt*, int iCol);
  ⊃{⋅SqliteStatement~StatementHandle|∘}
  Call "int" "sqlite3_column_type" FfiType!{StatementHandle "int"}
)

# Get the blob value of a column given an index in the result set of a prepared statement.
# Blob ? ColumnIndex:Int SqliteStatement
ColumnBlob ← (
  # https://www.sqlite.org/c3ref/column_blob.html
  &memcpy ⊃(
    # const void *sqlite3_column_blob(sqlite3_stmt*, int iCol);
    ⊃{⋅SqliteStatement~StatementHandle|∘}
    Call "byte*" "sqlite3_column_blob" FfiType!{StatementHandle "int"}
  | # int sqlite3_column_bytes(sqlite3_stmt*, int iCol);
    ⊃{⋅SqliteStatement~StatementHandle|∘}
    Call "int" "sqlite3_column_bytes" FfiType!{StatementHandle "int"}
  )
)

# Get the floating point value of a column given an index in the result set of a prepared statement.
# Float ? ColumnIndex:Int SqliteStatement
ColumnFloat ← (
  # https://www.sqlite.org/c3ref/column_blob.html
  # double sqlite3_column_double(sqlite3_stmt*, int iCol);
  ⊃{⋅SqliteStatement~StatementHandle|∘}
  Call "double" "sqlite3_column_double" FfiType!{StatementHandle "int"}
)

# Get the integer value of a column given an index in the result set of a prepared statement.
# Int ? ColumnIndex:Int SqliteStatement
ColumnInt ← (
  # https://www.sqlite.org/c3ref/column_blob.html
  # int sqlite3_column_int(sqlite3_stmt*, int iCol);
  ⊃{⋅SqliteStatement~StatementHandle|∘}
  Call "int" "sqlite3_column_int" FfiType!{StatementHandle "int"}
)

# Get the text value of a column given an index in the result set of a prepared statement.
# String ? ColumnIndex:Int SqliteStatement
ColumnText ← (
  # https://www.sqlite.org/c3ref/column_blob.html
  # const unsigned char *sqlite3_column_text(sqlite3_stmt*, int iCol);
  ⊃{⋅SqliteStatement~StatementHandle|∘}
  Call FfiType!String "sqlite3_column_text" FfiType!{StatementHandle "int"}
)

# Get the value of a column given an index in the result set of a prepared statement.
# This will return the appropriate value based on the column type (NULLs will ne represented by NaN).
# Value ? ColumnIndex:Int SqliteStatement
ColumnValue ← (
  ◡ColumnType
  ⍣(NaN◌◌ °Const~Null
  | ⍩ColumnInt °Const~Integer
  | ⍩ColumnFloat °Const~Float
  | ⍩ColumnText °Const~Text
  | ⍩ColumnBlob °Const~Blob
  | ˙⍤$"Unsupported column type: _"◌
  )
)

# Get all values of the current row in the result set of a prepared statement.
# Values ? SqliteStatement
RowValues ← (
  ⊃(⇡ColumnCount|¤)
  ≡(□ColumnValue)
)

# Gather all rows from the result set of a prepared statement.
# Values ? SqliteStatement
QueryValues ← ⍢(⟜RowValues|Step)

# Get a map of column names to their corresponding values in the result set of a prepared statement.
# ValueMap ? SqliteStatement
QueryValuesAsMap ← map⊃(ColumnNames|⍉QueryValues)

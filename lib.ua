# Experimental!

GetLibraryPath ↚ (
  ≍"windows"Os
  ⟨
    "bin/sqlite3.so"
  | ⊗□Arch{"x86" "x86_64"}
    ⟨"win32.dll"|"win64.dll"|0⍤"Unsupported architecture"0⟩
    ⊂"bin/sqlite3_"
  ⟩
  /($"___" ⊙Sep) {"." ThisFileDir ∘}
)

Lib ← &ffi ⊂□GetLibraryPath
Call ← Lib ⊂⊟∩□

SqliteOk ← 0
SqliteRow ← 100
SqliteDone ← 101

SqliteInteger ← 1
SqliteFloat ← 2
SqliteText ← 3
SqliteBlob ← 4
SqliteNull ← 5

Statement ← {$STMT ⊙($DB) ⊙∘}
GetStatementStmt ← °□⊡0
GetStatementDb ← °□⊡1

InferredTypeNull ← $NULL 0
InferredTypeInt ← $INT 1
InferredTypeFloat ← $FLOAT 2
InferredTypeText ← $TEXT 3
InferredTypeBlob ← $BLOB 4

IsNull ← ≍NaN
IsInt ← ⟨0|≍⁅.⟩/↧[⊃(=0type|≍[]△)].
IsFloat ← ⟨0|¬≍⁅.⟩/↧[⊃(=0type|≍[]△)].
IsText ← /↧[⊃(=2type|=1⧻△)]
IsBlob ← ⟨0|/↧≤255⟩/↧[⊃(=0type|=1⧻△)].

InferType ← (
  ⍣(⊢⊚[⊃(IsNull|IsInt|IsFloat|IsText|IsBlob)]|0⍤."Invalid value"◌)
  ⊡:[InferredTypeNull InferredTypeInt InferredTypeFloat InferredTypeText InferredTypeBlob]
)

# https://www.sqlite.org/c3ref/errcode.html
Err ← (
  {∘}
  Lib {"const char*" "sqlite3_errmsg" "const int*"}
)

# https://www.sqlite.org/c3ref/open.html
Open ← (
  {⊙0}
  Call "int" "sqlite3_open" {"const char*" "void**"}
  °{⊙∘}
  ⍤ $"Failed to open database: _" ⟜(≍SqliteOk)
  $DB
)

# https://www.sqlite.org/c3ref/close.html
Close ← (
  ⟜(
    {∘}
    Call "int" "sqlite3_close" {"const void*"}
  )
  ⟨⍤.$"Failed to close database: _" Err|◌⟩≍SqliteOk:
)

# https://www.sqlite.org/c3ref/exec.html
Exec ← (
  {⊙⊙(0 0 "www")}:
  Call "int" "sqlite3_exec" {"const void*" "const char*" "const void*" "const void*" "const char**"}
  °{⊙∘}
  ⟨⍤.$"Failed to exec: _"|◌⟩≍SqliteOk
)

# https://www.sqlite.org/c3ref/prepare.html
Prepare ← (
  ⊃(
    {⊙⊙(¯1 0 0)}:
    Call "int" "sqlite3_prepare_v2" {"const void*" "const char*" "int" "void**" "const char**"}
    °{⊙∘}↘¯1
  )(.⋅∘)
  ⟨⍤.$"Failed to prepare statement: _" Err:|⊙◌⟩≍SqliteOk
  Statement
)

# https://www.sqlite.org/c3ref/bind_blob.html
BindBlob ← (
  # TODO: This doesn't work, no idea why
  {⊙⊙⊙⊙∘} ⊃(⋅⋅GetStatementStmt|∘|⋅∘|⧻⋅∘|NULL|⋅⋅GetStatementDb)
  Call "int" "sqlite3_bind_blob" {"const void*" "const int" "const int*" "const int" "const void*"}
  ⟨⍤.$"Failed to bind blob: _" Err|◌⟩≍SqliteOk
)

BindInt ← (
  {⊙⊙∘} ⊃(⋅⋅GetStatementStmt|⊙∘|⋅⋅GetStatementDb)
  Call "int" "sqlite3_bind_int" {"const void*" "const int" "const int"}
  ⟨⍤.$"Failed to bind integer: _" Err|◌⟩≍SqliteOk
)

BindFloat ← (
  {⊙⊙∘} ⊃(⋅⋅GetStatementStmt|⊙∘|⋅⋅GetStatementDb)
  Call "int" "sqlite3_bind_double" {"const void*" "const int" "const double"}
  ⟨⍤.$"Failed to bind float: _" Err|◌⟩≍SqliteOk
)

BindNull ← (
  {⊙∘} ⊃(⋅GetStatementStmt|∘|⋅GetStatementDb)
  Call "int" "sqlite3_bind_null" {"const void*" "const int"}
  ⟨⍤.$"Failed to bind float: _" Err|◌⟩≍SqliteOk
)

BindText ← (
  # TODO: This doesn't work, no idea why
  {⊙⊙⊙⊙∘} ⊃(⋅⋅GetStatementStmt|∘|⋅∘|¯1|NULL|⋅⋅GetStatementDb)
  Call "int" "sqlite3_bind_text" {"const void*" "const int" "const char*" "int" "const void*"}
  ⟨⍤.$"Failed to bind text: _" Err|◌⟩≍SqliteOk
)

BindValue ← (
  ⊃(⋅InferType|⊙∘)
  ⟨BindNull⊙⊙◌|BindInt|BindFloat|BindText|BindBlob⟩
)

BindValues ← ⍚BindValue +1⇡⧻.⊙¤

# https://www.sqlite.org/c3ref/bind_parameter_index.html"
BindParameterIndex ← (
  {⊙∘} ⊃(⋅GetStatementStmt|∘|$"Invalid named parameter: \"_\""∘)
  Call "int" "sqlite3_bind_parameter_index" {"const void*" "const char*"}
  ⍤:⊙:>0.
)

BindNamed ← BindValue ⊃(BindParameterIndex⊙⋅∘|⋅⊙∘)

# https://www.sqlite.org/c3ref/step.html
Step ← (
  {∘} GetStatementStmt
  Call "int" "sqlite3_step" {"const void*"}
)

StepRow ← ≍SqliteRow Step

# https://www.sqlite.org/c3ref/column_count.html
ColumnCount ← (
  {∘} GetStatementStmt
  Call "int" "sqlite3_column_count" {"const void*"}
)

# https://www.sqlite.org/c3ref/column_name.html
ColumnName ← (
  {⊙∘} :⊙GetStatementStmt
  Call "char*" "sqlite3_column_name" {"const void*" "const int"}
)

# https://www.sqlite.org/c3ref/column_blob.html
ColumnType ← (
  {⊙∘} :⊙GetStatementStmt
  Call "int" "sqlite3_column_type" {"const void*" "const int"}
)

# https://www.sqlite.org/c3ref/column_blob.html
ColumnBlob ← (
  {⊙∘} :⊙GetStatementStmt
  0⍤."Returning a BLOB is currently unsupported"◌
  # TODO: This doesn't work as expected
  # Call "int*" "sqlite3_column_blob" {"const void*" "const int"}
)

# https://www.sqlite.org/c3ref/column_blob.html
ColumnFloat ← (
  {⊙∘} :⊙GetStatementStmt
  Call "double" "sqlite3_column_double" {"const void*" "const int"}
)

# https://www.sqlite.org/c3ref/column_blob.html
ColumnInt ← (
  {⊙∘} :⊙GetStatementStmt
  Call "int" "sqlite3_column_int" {"const void*" "const int"}
)

# https://www.sqlite.org/c3ref/column_blob.html
ColumnText ← (
  {⊙∘} :⊙GetStatementStmt
  Call "char*" "sqlite3_column_text" {"const void*" "const int"}
)

# Helper function to automatically infer column value and return it
ColumnValue ← (
  ⊃(⊙∘|⊙∘)
  ColumnType
  ⊗: [SqliteInteger SqliteFloat SqliteText SqliteBlob SqliteNull]
  ⟨ColumnInt|ColumnFloat|ColumnText|ColumnBlob|NaN⟩
)

# https://www.sqlite.org/c3ref/finalize.html
Finalize ← (
  {∘} ⊃(GetStatementStmt|GetStatementDb)
  Call "int" "sqlite3_finalize" {"const void*"}
  ⟨⍤.$"Failed to finalize statement: _" Err|◌⟩≍SqliteOk
)

ExecuteInsert ← (
  Step ⊃(∘|GetStatementDb|∘)
  ⟨⍤.$"Failed to execute insert statement: _" Err|◌⟩≍SqliteDone
  Finalize
)

GetColumnNames ← (
  ⊙¤⇡ColumnCount.
  ≡(□ColumnName)
)

QueryValuesInternal ↚ (
  ⟜(⊙[] ⇡ColumnCount)
  ⍢(
    ⟜(
      :¤⊙.
      ≡(□ColumnValue)
      :⊂⊃(⋅⋅∘|¤⊙∘)
    )
  )StepRow
  ◌◌
)

QueryValues ← ⊙Finalize QueryValuesInternal.

QueryMap ← (
  ⟜(QueryValuesInternal)
  ⟜(¤GetColumnNames)
  Finalize
  ≡(□map)
)

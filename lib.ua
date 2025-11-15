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

Lib  ← &ffi ? ⊂□GetLibraryPath
Call ← Lib ⊂⊟∩□

┌─╴Const
  Ok   ← 0
  Row  ← 100
  Done ← 101

  Integer ← 1
  Float   ← 2
  Text    ← 3
  Blob    ← 4
  Null    ← 5
└─╴

~Query {Statement Database}

┌─╴InferredType
  Null  ← $NULL 0
  Int   ← $INT 1
  Float ← $FLOAT 2
  Text  ← $TEXT 3
  Blob  ← $BLOB 4
└─╴

IsNull  ← ≍NaN
IsInt   ← ⨬(0|≍⁅.)/↧[⊃(=0type|≍[]△)].
IsFloat ← ⨬(0|¬≍⁅.)/↧[⊃(=0type|≍[]△)].
IsText  ← /↧[⊃(=2type|=1⧻△)]
IsBlob  ← ⨬(0|/↧≤255)/↧[⊃(=0type|=1⧻△)].

InferType ← (
  ⍣(⊢⊚[⊃(IsNull|IsInt|IsFloat|IsText|IsBlob)]|0⍤."Invalid value"◌)
  ⊡:InferredType![Null Int Float Text Blob]
)

# https://www.sqlite.org/c3ref/errcode.html
Err ← (
  {∘}
  Lib {"char*" "sqlite3_errmsg" "{int}*"}
)

# https://www.sqlite.org/c3ref/open.html
Open ← (
  {⊙0}
  Call "int" "sqlite3_open" {"char*" "out int*"}
  °{⊙∘}
  ⍤ $"Failed to open database: _" ⟜(≍Const~Ok)
  $DB
)

# https://www.sqlite.org/c3ref/close.html
Close ← (
  ⟜({∘}
    Call "int" "sqlite3_close" {"{int}*"}
  )
  ⨬(⍤.$"Failed to close database: _" Err|◌)≍Const~Ok:
)

# https://www.sqlite.org/c3ref/exec.html
Exec ← (
  {⊙⊙(0 0 "www")}:
  Call "int" "sqlite3_exec" {"void*" "char*" "void*" "void*" "char*"}
  °{⊙∘}
  ⨬(⍤.$"Failed to exec: _"|◌)≍Const~Ok
)

# # https://www.sqlite.org/c3ref/prepare.html
# Prepare ← (
#   ⊃({⊙⊙(¯1 0 0)}:
#     Call "int" "sqlite3_prepare_v2" {"const void*" "const char*" "int" "void**" "const char**"}
#     °{⊙∘}↘¯1
#   )(.⋅∘)
#   ⨬(⍤.$"Failed to prepare statement: _" Err:|⊙◌)≍SqliteOk
#   Statement
# )

# # https://www.sqlite.org/c3ref/bind_blob.html
# BindBlob ← (
#   # TODO: This doesn't work, no idea why
#   {⊙⊙⊙⊙∘} ⊃(⋅⋅GetStatementStmt|∘|⋅∘|⧻⋅∘|NULL|⋅⋅GetStatementDb)
#   Call "int" "sqlite3_bind_blob" {"const void*" "const int" "const int*" "const int" "const void*"}
#   ⨬(⍤.$"Failed to bind blob: _" Err|◌)≍SqliteOk
# )

# BindInt ← (
#   {⊙⊙∘} ⊃(⋅⋅GetStatementStmt|⊙∘|⋅⋅GetStatementDb)
#   Call "int" "sqlite3_bind_int" {"const void*" "const int" "const int"}
#   ⨬(⍤.$"Failed to bind integer: _" Err|◌)≍SqliteOk
# )

# BindFloat ← (
#   {⊙⊙∘} ⊃(⋅⋅GetStatementStmt|⊙∘|⋅⋅GetStatementDb)
#   Call "int" "sqlite3_bind_double" {"const void*" "const int" "const double"}
#   ⨬(⍤.$"Failed to bind float: _" Err|◌)≍SqliteOk
# )

# BindNull ← (
#   {⊙∘} ⊃(⋅GetStatementStmt|∘|⋅GetStatementDb)
#   Call "int" "sqlite3_bind_null" {"const void*" "const int"}
#   ⨬(⍤.$"Failed to bind float: _" Err|◌)≍SqliteOk
# )

# BindText ← (
#   # TODO: This doesn't work, no idea why
#   {⊙⊙⊙⊙∘} ⊃(⋅⋅GetStatementStmt|∘|⋅∘|¯1|NULL|⋅⋅GetStatementDb)
#   Call "int" "sqlite3_bind_text" {"const void*" "const int" "const char*" "int" "const void*"}
#   ⨬(⍤.$"Failed to bind text: _" Err|◌)≍SqliteOk
# )

# BindValue ← (
#   ⊃(⋅InferType|⊙∘)
#   ⨬(BindNull⊙◌|BindInt|BindFloat|BindText|BindBlob)
# )

# BindValues ← ⍚BindValue +1⇡⧻.⊙¤

# # https://www.sqlite.org/c3ref/bind_parameter_index.html"
# BindParameterIndex ← (
#   {⊙∘} ⊃(⋅GetStatementStmt|∘|$"Invalid named parameter: \"_\""∘)
#   Call "int" "sqlite3_bind_parameter_index" {"const void*" "const char*"}
#   ⍤:⊙:>0.
# )

# BindNamed ← BindValue ⊃(BindParameterIndex⊙⋅∘|⋅⊙∘)

# BindNamedMap ← ⍚BindNamed °map⊙¤

# # https://www.sqlite.org/c3ref/step.html
# Step ← (
#   {∘} GetStatementStmt
#   Call "int" "sqlite3_step" {"const void*"}
# )

# StepRow ← ≍SqliteRow Step

# # https://www.sqlite.org/c3ref/column_count.html
# ColumnCount ← (
#   {∘} GetStatementStmt
#   Call "int" "sqlite3_column_count" {"const void*"}
# )

# # https://www.sqlite.org/c3ref/column_name.html
# ColumnName ← (
#   {⊙∘} :⊙GetStatementStmt
#   Call "char*" "sqlite3_column_name" {"const void*" "const int"}
# )

# # https://www.sqlite.org/c3ref/column_blob.html
# ColumnType ← (
#   {⊙∘} :⊙GetStatementStmt
#   Call "int" "sqlite3_column_type" {"const void*" "const int"}
# )

# # https://www.sqlite.org/c3ref/column_blob.html
# ColumnBlob ← (
#   {⊙∘} :⊙GetStatementStmt
#   # 0⍤."Returning a BLOB is currently unsupported"◌
#   # TODO: This doesn't work as expected
#   Call "int*" "sqlite3_column_blob" {"const void*" "const int"}
# )

# # https://www.sqlite.org/c3ref/column_blob.html
# ColumnFloat ← (
#   {⊙∘} :⊙GetStatementStmt
#   Call "double" "sqlite3_column_double" {"const void*" "const int"}
# )

# # https://www.sqlite.org/c3ref/column_blob.html
# ColumnInt ← (
#   {⊙∘} :⊙GetStatementStmt
#   Call "int" "sqlite3_column_int" {"const void*" "const int"}
# )

# # https://www.sqlite.org/c3ref/column_blob.html
# ColumnText ← (
#   {⊙∘} :⊙GetStatementStmt
#   Call "char*" "sqlite3_column_text" {"const void*" "const int"}
# )

# # Helper function to automatically infer column value and return it
# ColumnValue ← (
#   ⊃(⊙∘|⊙∘)
#   ColumnType
#   ⊗: [SqliteInteger SqliteFloat SqliteText SqliteBlob SqliteNull]
#   ⨬(ColumnInt|ColumnFloat|ColumnText|ColumnBlob|NaN)
# )

# # https://www.sqlite.org/c3ref/finalize.html
# Finalize ← (
#   {∘} ⊃(GetStatementStmt|GetStatementDb)
#   Call "int" "sqlite3_finalize" {"const void*"}
#   ⨬(⍤.$"Failed to finalize statement: _" Err|◌)≍SqliteOk
# )

# ExecuteInsert ← (
#   Step ⊃(∘|GetStatementDb|∘)
#   ⨬(⍤.$"Failed to execute insert statement: _" Err|◌)≍SqliteDone
#   Finalize
# )

# GetColumnNames ← (
#   ⊙¤⇡ColumnCount.
#   ≡(□ColumnName)
# )

# QueryValuesInternal ↚ (
#   ⟜(⊙[] ⇡ColumnCount)
#   ⍢(⟜(:¤⊙.
#       ≡(□ColumnValue)
#       :⊂⊃(⋅⋅∘|¤⊙∘)
#     )
#   )StepRow
#   ◌◌
# )

# QueryValues ← ⊙Finalize QueryValuesInternal.

# QueryMap ← (
#   ⟜(QueryValuesInternal)
#   ⟜(¤GetColumnNames)
#   Finalize
#   ≡(□map)
# )

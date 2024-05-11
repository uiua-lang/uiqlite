# Experimental!

GetLibraryPath ↚ (
  ≍"windows"Os
  ⟨
    "bin/sqlite3.so"
  | ⊗□Arch{"x86" "x86_64"}
    ⟨"win32.dll"|"win64.dll"|0⍤"Unsupported architecture"0⟩
    ⊂"bin/sqlite3_"
  ⟩
)

Lib ← &ffi ⊂□GetLibraryPath
Call ← Lib ⊂⊟∩□

StatusOK ← 0
SqliteRow ← 100

Statement ← {$STMT ⊙($DB) ⊙∘}
GetStatementStmt ← °□⊡0
GetStatementDb ← °□⊡1

# https://www.sqlite.org/c3ref/errcode.html
Err ← Lib {"const char*" "sqlite3_errmsg" "const int*"} {∘}

# https://www.sqlite.org/c3ref/open.html
Open ← (
  {⊙0}
  Call "int" "sqlite3_open" {"const char*" "void**"}
  °{⊙∘}
  ⍤ $"Failed to open database: _" ⟜(≍StatusOK)
  $DB
)

# https://www.sqlite.org/c3ref/close.html
Close ← (
  ⟜(
    {∘}
    Call "int" "sqlite3_close" {"const void*"}
  )
  ⟨⍤.$"Failed to close database: _" Err|◌⟩≍StatusOK:
)

# https://www.sqlite.org/c3ref/exec.html
Exec ← (
  {⊙⊙(0 0 "www")}:
  Call "int" "sqlite3_exec" {"const void*" "const char*" "const void*" "const void*" "const char**"}
  °{⊙∘}
  ⟨⍤.$"Failed to exec: _"|◌⟩≍StatusOK
)

# https://www.sqlite.org/c3ref/prepare.html
Prepare ← (
  ⊃(
    {⊙⊙(¯1 0 0)}:
    Call "int" "sqlite3_prepare_v2" {"const void*" "const char*" "int" "void**" "const char**"}
    °{⊙∘}↘¯1
  )(.⋅∘)
  ⟨⍤.$"Failed to prepare statement: _" Err:|⊙◌⟩≍StatusOK
  Statement
)

# https://www.sqlite.org/c3ref/step.html
Step ← (
  {∘} GetStatementStmt
  Call "int" "sqlite3_step" {"const void*"}
  ≍SqliteRow
)

# https://www.sqlite.org/c3ref/column_blob.html
ColumnText ← (
  {⊙∘} :⊙GetStatementStmt
  Call "char*" "sqlite3_column_text" {"const void*" "const int"}
)

# https://www.sqlite.org/c3ref/finalize.html
Finalize ← (
  {∘} ⊃(GetStatementStmt|GetStatementDb)
  Call "int" "sqlite3_finalize" {"const void*"}
  ⟨⍤.$"Failed to finalize statement: _" Err|◌⟩≍StatusOK
)

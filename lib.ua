# Experimental!

DllPath ← ⊡1&args
Lib ← &ffi ⊂□DllPath

SqliteStatusOK ← 0

SqliteErr ← Lib {"const char*" "sqlite3_errmsg" "const int*"} {∘}
# https://www.sqlite.org/c3ref/open.html
SqliteOpen ← (
  {⊙Uninit}
  Lib {"int" "sqlite3_open" "const char*" "void**"}
  °{⊙∘}
  ⍤ "Failed to open database: _" ≍SqliteStatusOK
  $Db
)
SqliteClose ← (
  ⟜(Lib {"int" "sqlite3_close" "const void*"} {∘})
  ⟨⍤.$"Failed to close database: _" SqliteErr|◌⟩≍SqliteStatusOK:
)
SqlitePrepare ← (
  ⟜(
    {⊙⊙(¯1 Uninit NULL)}
    Lib {"int" "sqlite3_prepare_v2" "const void*" "const char*" "int" "void**" "const char**"}
    °{⊙∘}↘¯1
  )
  ⟨⍤.$"Failed to prepare stmt: _" SqliteErr|◌⟩≍SqliteStatusOK:
  $Stmt
)
SqliteStep ← (
  ⟜(Lib {"int" "sqlite3_step" "const void*"} {∘})
  ⟨⍤.$"Failed to step stmt: _" SqliteErr|◌⟩≍SqliteStatusOK:
)
SqliteFinalize ← (
  ⟜(Lib {"int" "sqlite3_finalize" "const void*"} {∘})
  ⟨⍤.$"Failed to finalize stmt: _" SqliteErr|◌⟩≍SqliteStatusOK:
)

SqliteOpen "test.db"
⟜SqlitePrepare:"CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT);"
⊙(SqliteFinalize⟜SqliteStep)
SqliteClose

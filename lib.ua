# Experimental!

DllPath ← ⍣(⊡1&args|⊂"sqlite3."DllExt)
Lib ← &ffi ⊂□DllPath

StatusOK ← 0

Err ← Lib {"const char*" "sqlite3_errmsg" "const int*"} {∘}
# https://www.sqlite.org/c3ref/open.html
Open ← (
  {⊙0}
  Lib {"int" "sqlite3_open"
       "const char*" "void**"}
  °{⊙∘}
  ⍤ $"Failed to open database: _" ⟜(≍StatusOK)
  $Db
)
Close ← (
  ⟜(Lib {"int" "sqlite3_close" "const void*"} {∘})
  ⟨⍤.$"Failed to close database: _" Err|◌⟩≍StatusOK:
)
Exec ← (
  {⊙⊙(0 0 "www")}:
  Lib {"int" "sqlite3_exec"
       "const void*" "const char*" "const void*" "const void*" "const char**"}
  °{⊙∘}
  ⟨⍤.$"Failed to exec: _"|◌⟩≍StatusOK
)
Prepare ← (
  ⊃(
    {⊙⊙(¯1 0 0)}:
    Lib {"int" "sqlite3_prepare_v2"
         "const void*" "const char*" "int" "void**" "const char**"}
    °{⊙∘}↘¯1
  )⋅∘
  ⟨⍤.$"Failed to prepare stmt: _" Err:|⊙◌⟩≍StatusOK
  $Stmt
)
Step ← (
  Lib {"int" "sqlite3_step" "const void*"} {∘}
  ⟨⍤.$"Failed to step stmt: _" Err|◌⟩≍StatusOK
)
Finalize ← (
  Lib {"int" "sqlite3_finalize" "const void*"} {∘}
  ⟨⍤.$"Failed to finalize stmt: _" Err|◌⟩≍StatusOK
)

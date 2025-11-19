#include "uiua_compat.h"

/**
 * There are issues with sqlite3_bind_text and sqlite3_bind_blob where you cannot
 * properly specify the destructor over FFI that works consistently. These functions
 * are a workaround by providing versions that hardcode the destructors.
 */

/* Bind text with transient destructor */
int sqlite3_bind_text_transient(sqlite3_stmt *stmt, int index, const char *value, int numBytes)
{
    return sqlite3_bind_text(stmt, index, value, numBytes, SQLITE_TRANSIENT);
}

/* Bind text with static destructor */
int sqlite3_bind_text_static(sqlite3_stmt *stmt, int index, const char *value, int numBytes)
{
    return sqlite3_bind_text(stmt, index, value, numBytes, SQLITE_STATIC);
}

/* Bind blob with transient destructor */
int sqlite3_bind_blob_transient(sqlite3_stmt *stmt, int index, const void *value, int numBytes)
{
    return sqlite3_bind_blob(stmt, index, value, numBytes, SQLITE_TRANSIENT);
}

/* Bind blob with static destructor */
int sqlite3_bind_blob_static(sqlite3_stmt *stmt, int index, const void *value, int numBytes)
{
    return sqlite3_bind_blob(stmt, index, value, numBytes, SQLITE_STATIC);
}

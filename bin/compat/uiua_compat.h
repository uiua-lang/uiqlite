#ifndef UIUA_COMPAT_H
#define UIUA_COMPAT_H

#include "sqlite3.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Bind text with transient destructor */
int sqlite3_bind_text_transient(sqlite3_stmt *stmt, int index, const char *value, int numBytes);

/* Bind text with static destructor */
int sqlite3_bind_text_static(sqlite3_stmt *stmt, int index, const char *value, int numBytes);

/* Bind blob with transient destructor */
int sqlite3_bind_blob_transient(sqlite3_stmt *stmt, int index, const void *value, int numBytes);

/* Bind blob with static destructor */
int sqlite3_bind_blob_static(sqlite3_stmt *stmt, int index, const void *value, int numBytes);

#ifdef __cplusplus
}
#endif

#endif /* UIUA_COMPAT_H */
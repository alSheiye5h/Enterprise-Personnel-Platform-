#ifndef TRANSACTION_MANAGER_H
#define TRANSACTION_MANAGER_H

#include "storage_engine.h"

// ==================== ACID TRANSACTION MANAGER ====================

typedef enum {
    TX_NEW,
    TX_ACTIVE,
    TX_COMMITTING,
    TX_COMMITTED,
    TX_ROLLING_BACK,
    TX_ROLLED_BACK,
    TX_ERROR
} TransactionState;

// Complete Transaction Context
typedef struct {
    int transaction_id;
    TransactionState state;
    struct tm start_time;
    struct tm end_time;
    
    // Undo/Redo Logs
    struct {
        void* before_image;
        void* after_image;
        int record_id;
        char operation[10];
    } undo_log[1000];
    int undo_count;
    
    struct {
        void* data;
        int record_id;
        char operation[10];
    } redo_log[1000];
    int redo_count;
    
    // Locks held
    struct {
        int record_ids[100];
        char lock_types[100];  // S=Shared, X=Exclusive
        int count;
    } locks;
    
    // Savepoints
    struct {
        char name[50];
        int undo_count_snapshot;
        int redo_count_snapshot;
    } savepoints[10];
    int savepoint_count;
    
} ACIDTransaction;

// ==================== LOCK MANAGER ====================

typedef struct {
    int record_id;
    char lock_type;            // 'S' or 'X'
    int transaction_id;
    struct tm grant_time;
    pthread_cond_t condition;
    
} LockEntry;

typedef struct {
    LockEntry* locks;
    int lock_count;
    pthread_mutex_t lock_table_mutex;
    
    // Deadlock detection
    int** wait_for_graph;
    int graph_size;
    
} LockManager;

// ==================== RECOVERY MANAGER ====================

typedef struct {
    // Write-Ahead Log (WAL)
    FILE* wal_file;
    size_t wal_position;
    
    // Checkpoint information
    struct {
        struct tm checkpoint_time;
        int active_transactions[100];
        int active_count;
        size_t wal_position;
    } checkpoint;
    
    // Recovery procedures
    void (*recovery_callback)(int, void*);
    
} RecoveryManager;

// ==================== TRANSACTION API ====================

// Begin transaction with isolation level
ACIDTransaction* tx_begin(int isolation_level);
#define ISOLATION_READ_UNCOMMITTED  0
#define ISOLATION_READ_COMMITTED    1
#define ISOLATION_REPEATABLE_READ   2
#define ISOLATION_SERIALIZABLE      3

// Transaction operations
int tx_insert(ACIDTransaction* tx, const EmployeeRecord* record);
int tx_update(ACIDTransaction* tx, int record_id, const EmployeeRecord* record);
int tx_delete(ACIDTransaction* tx, int record_id);
EmployeeRecord* tx_read(ACIDTransaction* tx, int record_id);

// Savepoint management
int tx_savepoint(ACIDTransaction* tx, const char* name);
int tx_rollback_to_savepoint(ACIDTransaction* tx, const char* name);

// Commit with two-phase protocol
int tx_prepare(ACIDTransaction* tx);
int tx_commit(ACIDTransaction* tx);
int tx_rollback(ACIDTransaction* tx);

// ==================== CONCURRENCY CONTROL ====================

// Lock management
int acquire_lock(LockManager* lm, int tx_id, int record_id, char lock_type);
int release_lock(LockManager* lm, int tx_id, int record_id);
int upgrade_lock(LockManager* lm, int tx_id, int record_id);

// Deadlock detection
int detect_deadlock(LockManager* lm);
void* deadlock_detector_thread(void* arg);

// ==================== RECOVERY PROCEDURES ====================

// Crash recovery
int recover_from_crash(FileManager* fm, RecoveryManager* rm);

// Media recovery
int recover_from_backup(FileManager* fm, const char* backup_path, 
                       struct tm recovery_point);

// Log management
void write_wal_entry(RecoveryManager* rm, const char* operation, 
                    void* before, void* after, int record_id);
void force_wal(RecoveryManager* rm);

// ==================== DISTRIBUTED TRANSACTIONS ====================

typedef struct {
    char coordinator_url[200];
    char participant_urls[10][200];
    int participant_count;
    
    // Two-phase commit protocol
    int prepare_all();
    int commit_all();
    int rollback_all();
    
} DistributedTransaction;

#endif // TRANSACTION_MANAGER_H
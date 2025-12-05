#ifndef STORAGE_ENGINE_H
#define STORAGE_ENGINE_H

#include "database_schema.h"

// ==================== PHYSICAL STORAGE STRUCTURES (MPD) ====================

// File Header Structure (MPD: Physical organization)
typedef struct {
    char magic_number[4];        // "HRDB"
    int version;
    char created_date[20];
    char last_modified[20];
    int record_size;
    int record_count;
    int free_list_head;          // For deleted records
    int index_root;              // B+ Tree root node
    int checksum;
    
} FileHeader;

// Fixed-length Record Structure (MPD: Physical record layout)
typedef struct {
    // Employee Record - Fixed Length for Direct Access
    struct {
        int record_id;           // Physical record number
        int is_deleted;          // Tombstone flag
        int next_free;           // For free list
        
        // Padded fields for fixed length
        char employee_code[20];
        char first_name[50];
        char last_name[50];
        char gender[1];
        char date_of_birth[11];  // YYYY-MM-DD
        char hire_date[11];
        
        // Foreign keys as integers
        int department_id;
        int job_id;
        
        // Status flags as bitset
        unsigned int flags;
        #define FLAG_ACTIVE      0x01
        #define FLAG_ON_LEAVE    0x02
        #define FLAG_PROBATION   0x04
        #define FLAG_TERMINATED  0x08
        
        // Padding to fixed size
        char padding[64];        // Total record size = 256 bytes
        
    } EmployeePhysicalRecord;

    // Department Record
    struct {
        int record_id;
        int is_deleted;
        char department_code[20];
        char department_name[100];
        int parent_id;
        int location_id;
        char cost_center[20];
        double annual_budget;
        char padding[40];
        
    } DepartmentPhysicalRecord;

} PhysicalRecords;

// ==================== B+ TREE INDEX (MPD: Physical indexing) ====================

// B+ Tree Node Structure
typedef struct BTreeNode {
    int is_leaf;
    int key_count;
    int keys[127];               // 4K block / 32 bytes per key = 128 keys
    union {
        struct BTreeNode* children[128];  // For internal nodes
        int record_pointers[128];         // For leaf nodes
    } data;
    struct BTreeNode* next;      // For leaf node linked list
    
} BTreeNode;

// Primary Index
typedef struct {
    BTreeNode* root;
    int key_type;                // 0=int, 1=string
    int key_size;
    char index_file[100];
    
} PrimaryIndex;

// Secondary Index (Inverted)
typedef struct {
    char key[100];               // Department code, Job code, etc.
    int* employee_ids;           // List of employees
    int count;
    int allocated;
    
} SecondaryIndex;

// ==================== FILE MANAGER ====================

typedef struct {
    FILE* data_file;
    FILE* index_file;
    FILE* transaction_log;
    
    // Memory Mapped Files for performance
    void* data_map;
    size_t data_size;
    
    // Cache
    struct {
        PhysicalRecords* records;
        int* lru_queue;
        int cache_size;
        int hit_count;
        int miss_count;
    } cache;
    
    // Locking
    pthread_rwlock_t file_lock;
    
} FileManager;

// ==================== STORAGE OPERATIONS ====================

// Initialize storage engine
FileManager* storage_init(const char* base_path);

// CRUD Operations with ACID properties
int storage_insert(FileManager* fm, const EmployeeRecord* record);
int storage_update(FileManager* fm, int record_id, const EmployeeRecord* record);
int storage_delete(FileManager* fm, int record_id, int soft_delete);
EmployeeRecord* storage_read(FileManager* fm, int record_id);

// Index Operations
void build_index(FileManager* fm);
int search_by_key(FileManager* fm, const char* key, int* results, int max_results);

// Transaction Management
typedef struct {
    int transaction_id;
    struct tm start_time;
    char transaction_type[20];  // INSERT, UPDATE, DELETE
    int affected_records[100];
    int record_count;
    void* before_image;         // For rollback
    void* after_image;          // For commit
    
} Transaction;

// Begin transaction
Transaction* transaction_begin(FileManager* fm, const char* type);

// Commit transaction
int transaction_commit(FileManager* fm, Transaction* trans);

// Rollback transaction
int transaction_rollback(FileManager* fm, Transaction* trans);

// ==================== DATA COMPRESSION ====================

// Compress record for storage
typedef struct {
    unsigned char* data;
    size_t size;
    char compression_type[10];  // LZ4, ZSTD, RLE
    
} CompressedRecord;

CompressedRecord compress_record(const void* record, size_t size);
void* decompress_record(const CompressedRecord* comp_rec);

// ==================== BACKUP & RECOVERY ====================

typedef struct {
    char backup_id[50];
    struct tm backup_time;
    char backup_type[20];       // FULL, INCREMENTAL, DIFFERENTIAL
    char backup_file[200];
    double size_mb;
    int checksum;
    
} BackupInfo;

// Create backup
BackupInfo* create_backup(FileManager* fm, const char* backup_type);

// Restore from backup
int restore_backup(FileManager* fm, const char* backup_id);

// Point-in-time recovery
int recover_to_timestamp(FileManager* fm, struct tm recovery_point);

#endif // STORAGE_ENGINE_H
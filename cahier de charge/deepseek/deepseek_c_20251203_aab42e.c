#ifndef DATABASE_SCHEMA_H
#define DATABASE_SCHEMA_H

#include "business_entities.h"
#include <stdbool.h>

// ==================== LOGICAL DATA MODEL (MLD) ====================
// Normalized database schema (3rd Normal Form)

// MLD: Employee Table (Normalized from MCD Entity)
typedef struct {
    // Primary Key (Surrogate Key for database)
    int employee_id;              // Auto-increment, system-generated
    char employee_code[20];       // Alternate Key (Business Key)
    
    // Personal Data (1NF - Atomic values)
    char first_name[50];
    char last_name[50];
    char gender;
    struct tm date_of_birth;
    
    // Foreign Keys (Relationships)
    int department_id;           // References Department
    int job_id;                  // References Job
    int manager_id;              // Self-reference (nullable)
    
    // Contact Info (Could be in separate table for 3NF)
    int contact_info_id;         // Foreign key to Contact table
    
    // Status Fields
    int employment_status_id;
    struct tm hire_date;
    struct tm termination_date;
    
    // System Fields (MLD additions)
    struct tm created_date;
    struct tm last_modified;
    char created_by[50];
    char modified_by[50];
    int version;                 // For optimistic locking
    
} EmployeeRecord;

// MLD: Department Table
typedef struct {
    int department_id;
    char department_code[20];
    char department_name[100];
    int parent_department_id;    // Hierarchical self-reference
    int location_id;             // Foreign key to Location table
    int manager_employee_id;     // Foreign key to Employee
    double annual_budget;
    
    // Normalized from MCD
    char cost_center_code[20];
    char department_type[30];
    
} DepartmentRecord;

// MLD: Contact Information (3NF - Separate entity)
typedef struct {
    int contact_id;
    int employee_id;             // Foreign key
    char email_personal[100];
    char email_corporate[100];
    char phone_mobile[20];
    char phone_home[20];
    char address_line1[100];
    char address_line2[100];
    char city[50];
    char state[50];
    char postal_code[20];
    char country_code[5];        // Foreign key to Country
    
} ContactRecord;

// MLD: Payroll Transaction (Normalized)
typedef struct {
    int payroll_id;
    int employee_id;
    struct tm period_start;
    struct tm period_end;
    
    // Earnings Breakdown (1NF - Could be separate table)
    struct {
        double basic;
        double housing;
        double transport;
        double overtime;
        double bonus;
        double commission;
    } earnings;
    
    // Deductions Breakdown
    struct {
        double income_tax;
        double social_security;
        double health_insurance;
        double pension;
        double loan;
        double other;
    } deductions;
    
    // Calculated Fields
    double gross_pay;
    double total_deductions;
    double net_pay;
    
    // Status and Audit
    char status[20];
    struct tm processed_date;
    int processed_by_employee_id;
    
} PayrollRecord;

// MLD: Payroll Items (4NF - Many-to-many resolved)
typedef struct {
    int item_id;
    int payroll_id;
    char item_type[30];          // EARNING or DEDUCTION
    char item_code[20];          // BASIC, OVERTIME, TAX, etc.
    char description[100];
    double amount;
    char currency[5];
    double exchange_rate;
    int tax_category_id;         // Foreign key
    
} PayrollItemRecord;

// MLD: Time Attendance (Normalized)
typedef struct {
    int attendance_id;
    int employee_id;
    struct tm work_date;
    
    // Time Data
    struct tm clock_in;
    struct tm clock_out;
    struct tm break_start;
    struct tm break_end;
    
    // Calculated
    double regular_hours;
    double overtime_hours;
    double night_hours;
    double holiday_hours;
    
    // Relationships
    int shift_id;               // Foreign key to Shift
    int project_id;             // Optional: Project tracking
    
    // Approval Workflow
    int approved_by_id;
    struct tm approved_date;
    char approval_status[20];
    
} AttendanceRecord;

// MLD: Leave Management (Normalized)
typedef struct {
    int leave_id;
    int employee_id;
    int leave_type_id;          // Foreign key
    struct tm start_date;
    struct tm end_date;
    
    // Calculated
    double total_days;
    double working_days;
    double calendar_days;
    
    // Balance Tracking
    double balance_before;
    double balance_after;
    
    // Workflow
    int requested_by_id;
    int approved_by_id;
    struct tm request_date;
    struct tm approval_date;
    char status[20];
    
    // Supporting Docs
    char document_path[200];
    bool is_medical;
    
} LeaveRecord;

// MLD: Tax Configuration (Reference Data)
typedef struct {
    int tax_config_id;
    char country_code[5];
    int tax_year;
    char tax_authority[100];
    
    // Bracket Table (1NF - Fixed array, could be separate table)
    struct {
        double min_income;
        double max_income;
        double rate;
        double fixed_amount;
    } brackets[20];
    int bracket_count;
    
    // Allowances
    double personal_allowance;
    double married_allowance;
    double dependent_allowance;
    
    // Effective Dates
    struct tm effective_from;
    struct tm effective_to;
    
} TaxConfigRecord;

// MLD: Skills Matrix (Bridge Table for N:M)
typedef struct {
    int employee_skill_id;
    int employee_id;
    int skill_id;
    char proficiency_level[20];
    struct tm certified_date;
    char certified_by[50];
    struct tm expiry_date;
    
} EmployeeSkillRecord;

// ==================== DATABASE SCHEMA DEFINITION ====================

typedef struct {
    // Tables (MLD Entities)
    EmployeeRecord* employees;
    DepartmentRecord* departments;
    ContactRecord* contacts;
    PayrollRecord* payrolls;
    PayrollItemRecord* payroll_items;
    AttendanceRecord* attendance;
    LeaveRecord* leaves;
    TaxConfigRecord* tax_configs;
    EmployeeSkillRecord* employee_skills;
    
    // Metadata
    int employee_count;
    int department_count;
    int payroll_count;
    
    // Indexes (Logical)
    struct {
        int* by_employee_id;
        int* by_department;
        int* by_job;
        // ... other indexes
    } indexes;
    
} DatabaseSchema;

// ==================== NORMALIZATION FUNCTIONS ====================

// Convert MCD entity to MLD normalized records
void normalize_employee(const EmployeeEntity* entity, 
                       EmployeeRecord* emp_rec,
                       ContactRecord* contact_rec);

// Denormalize for reporting (star schema)
typedef struct {
    // Fact Table
    int payroll_id;
    int employee_id;
    int department_id;
    int job_id;
    int time_id;  // Year-Month
    
    // Measures
    double gross_salary;
    double net_salary;
    double tax_amount;
    double overtime_hours;
    
} PayrollFactTable;

// Dimension Tables
typedef struct {
    int employee_id;
    char employee_code[20];
    char full_name[100];
    char department_name[50];
    char job_title[50];
    char employment_status[20];
    
} EmployeeDimension;

typedef struct {
    int time_id;
    int year;
    int month;
    int quarter;
    char month_name[20];
    
} TimeDimension;

#endif // DATABASE_SCHEMA_H
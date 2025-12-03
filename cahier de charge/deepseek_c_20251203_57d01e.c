#ifndef BUSINESS_ENTITIES_H
#define BUSINESS_ENTITIES_H

#include <time.h>

// ==================== CONCEPTUAL ENTITIES (MCD) ====================
// These represent BUSINESS CONCEPTS, not implementation details

// MERISE MCD: Entity "Employee" with business attributes
typedef struct {
    // Business Identifier (Natural Key)
    char employee_code[20];      // HR-EMP-001 (Business ID)
    char national_id[20];        // Social Security Number
    char passport_number[20];    // For international employees
    
    // Personal Information
    char first_name[50];
    char last_name[50];
    char middle_name[30];
    char gender;                 // M/F/O
    struct tm date_of_birth;
    char marital_status[15];     // Single, Married, Divorced
    int dependents_count;        // For tax calculations
    
    // Contact Information
    char personal_email[100];
    char corporate_email[100];
    char phone_mobile[20];
    char phone_home[20];
    char address_line1[100];
    char address_line2[100];
    char city[50];
    char state[50];
    char postal_code[20];
    char country[50];
    
    // Emergency Contact
    char emergency_contact_name[100];
    char emergency_contact_phone[20];
    char emergency_contact_relation[30];
    
    // Business Attributes (MCD Relationships)
    char department_code[20];    // Relationship to Department
    char job_position_code[20];  // Relationship to Job
    char manager_code[20];       // Self-referencing relationship
    
    // Status (Business State)
    char employment_status[20];  // Active, OnLeave, Terminated
    struct tm hire_date;
    struct tm probation_end_date;
    struct tm termination_date;
    char termination_reason[50];
    
    // Compliance Flags
    int has_signed_contract;
    int has_background_check;
    int is_verified;
    
    // Business Rules Validation
    int is_valid;  // Derived attribute (business rule)
    
} EmployeeEntity;  // Pure MCD Entity

// MERISE MCD: Entity "Department"
typedef struct {
    char department_code[20];    // DEP-IT, DEP-HR
    char department_name[100];
    char department_type[30];    // Function, Project, Cost Center
    char cost_center_code[20];
    char location_code[20];
    char manager_code[20];       // Relationship to Employee
    struct tm established_date;
    double annual_budget;
    int headcount_approved;
    int headcount_current;
    
    // Hierarchical Structure
    char parent_department_code[20];
    int hierarchy_level;
    
} DepartmentEntity;

// MERISE MCD: Entity "Job Position"
typedef struct {
    char job_code[20];           // JOB-DEV-001
    char job_title[100];
    char job_family[50];         // Technical, Administrative, Managerial
    char job_grade[10];          // G7, G8
    char eeo_category[10];       // Equal Employment Opportunity
    
    // Compensation Range (Business Rule)
    double salary_min;
    double salary_mid;
    double salary_max;
    char currency[5];            // USD, EUR, GBP
    
    // Requirements
    int experience_years_required;
    char education_level[50];
    char[] required_certifications;  // Dynamic array
    
} JobPositionEntity;

// MERISE MCD: Entity "Payroll" (Business Transaction)
typedef struct {
    char payroll_id[30];         // PAY-2024-01-EMP001
    char employee_code[20];      // Relationship
    struct tm period_start;
    struct tm period_end;
    struct tm payment_date;
    
    // Earnings (MCD: Aggregation of Payroll Items)
    double basic_salary;
    double housing_allowance;
    double transportation_allowance;
    double overtime_pay;
    double performance_bonus;
    double commission;
    double other_allowances;
    double total_earnings;
    
    // Deductions (MCD: Aggregation)
    double income_tax;
    double social_security_employee;
    double social_security_employer;
    double health_insurance;
    double pension_contribution;
    double loan_deductions;
    double other_deductions;
    double total_deductions;
    
    // Net Pay (Derived Attribute - Business Rule)
    double net_pay;
    
    // Payment Details
    char payment_method[20];     // Bank Transfer, Cash, Check
    char bank_account_number[30];
    char bank_name[50];
    char payment_status[20];     // Pending, Paid, Failed
    
    // Compliance
    char tax_certificate_number[30];
    int is_tax_filed;
    
} PayrollEntity;

// MERISE MCD: Entity "Attendance" (Business Event)
typedef struct {
    char attendance_id[30];      // ATT-2024-01-01-EMP001
    char employee_code[20];
    struct tm date;
    
    // Time Tracking
    struct tm scheduled_start;
    struct tm scheduled_end;
    struct tm actual_start;
    struct tm actual_end;
    
    // Calculations (Business Rules)
    double scheduled_hours;
    double actual_hours;
    double regular_hours;
    double overtime_hours;
    double night_hours;
    double holiday_hours;
    
    // Status
    char attendance_status[20];  // Present, Absent, Late, Half-day
    char shift_code[20];         // Morning, Evening, Night
    char approval_status[20];    // Pending, Approved, Rejected
    char approver_code[20];      // Relationship
    
    // Notes
    char remarks[200];
    
} AttendanceEntity;

// MERISE MCD: Entity "Leave" (Business Process)
typedef struct {
    char leave_id[30];           // LVE-2024-EMP001-001
    char employee_code[20];
    char leave_type[30];         // Annual, Sick, Maternity, Unpaid
    struct tm start_date;
    struct tm end_date;
    double total_days;
    
    // Workflow States (MCT Process)
    char request_status[20];     // Draft, Submitted, Approved, Rejected
    struct tm request_date;
    struct tm approval_date;
    char approver_code[20];
    
    // Business Rules
    double days_deducted;
    char supporting_document_path[200];
    int is_medical;
    char medical_certificate_number[30];
    
    // Relationship to Payroll
    int is_paid_leave;
    
} LeaveEntity;

// MERISE MCD: Entity "Contract" (Legal Agreement)
typedef struct {
    char contract_id[30];        // CNT-EMP001-2024
    char employee_code[20];
    char contract_type[30];      // Permanent, Fixed-Term, Probation
    struct tm start_date;
    struct tm end_date;
    struct tm signing_date;
    
    // Terms and Conditions
    double basic_salary;
    char salary_currency[5];
    int working_hours_per_week;
    int probation_period_days;
    int notice_period_days;
    
    // Benefits (MCD: Composition)
    int has_health_insurance;
    int has_pension;
    int has_stock_options;
    double annual_leave_days;
    double sick_leave_days;
    
    // Documents
    char contract_file_path[200];
    char signed_copy_path[200];
    int is_digital_signature;
    
} ContractEntity;

// MERISE MCD: Entity "Tax Configuration" (Business Rules)
typedef struct {
    char country_code[5];        // US, UK, FR, DE
    int tax_year;
    
    // Tax Brackets (MCD: Multi-valued attribute)
    struct TaxBracket {
        double min_income;
        double max_income;
        double tax_rate;         // Percentage
        double fixed_amount;
    } brackets[10];
    int bracket_count;
    
    // Allowances
    double personal_allowance;
    double married_allowance;
    double dependent_allowance;
    
    // Social Security
    double employee_rate;
    double employer_rate;
    double max_contribution;
    
    // Filing
    char tax_form_code[20];
    struct tm filing_deadline;
    
} TaxConfigEntity;

// ==================== MCD RELATIONSHIPS ====================
// These define how entities relate in the business domain

typedef struct {
    // 1:N Relationship - Employee works in Department
    char employee_code[20];
    char department_code[20];
    struct tm assignment_date;
    char assignment_type[30];    // Primary, Matrix, Temporary
    double allocation_percentage; // For part-time allocations
    
} WorksInRelationship;

typedef struct {
    // 1:1 Relationship - Employee has Job Position
    char employee_code[20];
    char job_code[20];
    struct tm effective_date;
    struct tm end_date;
    char grade_level[10];
    
} HasJobRelationship;

typedef struct {
    // N:M Relationship - Employee possesses Skills
    char employee_code[20];
    char skill_code[20];
    char proficiency_level[20];  // Beginner, Intermediate, Expert
    struct tm certification_date;
    char certified_by[50];
    
} PossessesSkillRelationship;

#endif // BUSINESS_ENTITIES_H
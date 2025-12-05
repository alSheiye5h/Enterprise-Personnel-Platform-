#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "business_entities.h"
#include "database_schema.h"
#include "storage_engine.h"
#include "transaction_manager.h"

// ==================== MERISE WORKFLOW ====================

void merise_workflow() {
    printf("=== MERISE HR/Payroll System ===\n");
    
    // PHASE 1: ABSTRACT CYCLE
    printf("\n1. ABSTRACT CYCLE - Business Modeling\n");
    printf("   • Creating MCD Entities...\n");
    
    // Create MCD Entity (Business Concept)
    EmployeeEntity mcd_employee = {
        .employee_code = "HR-EMP-1001",
        .national_id = "123-45-6789",
        .first_name = "John",
        .last_name = "Doe",
        .department_code = "DEPT-IT",
        .job_position_code = "JOB-DEV-001",
        .hire_date = {.tm_year = 124, .tm_mon = 0, .tm_mday = 15},
        .employment_status = "Active"
    };
    
    // PHASE 2: DECISION CYCLE
    printf("\n2. DECISION CYCLE - Logical Design\n");
    printf("   • Normalizing to MLD...\n");
    
    // Convert MCD to MLD (Normalization)
    EmployeeRecord mld_employee;
    ContactRecord mld_contact;
    normalize_employee(&mcd_employee, &mld_employee, &mld_contact);
    
    // PHASE 3: PHYSICAL CYCLE
    printf("\n3. PHYSICAL CYCLE - Implementation\n");
    printf("   • Initializing storage engine...\n");
    
    // Initialize storage (MPD)
    FileManager* fm = storage_init("./data");
    
    // Begin transaction (MOP)
    ACIDTransaction* tx = tx_begin(ISOLATION_READ_COMMITTED);
    
    printf("\n4. EXECUTING BUSINESS PROCESS...\n");
    
    // Insert employee
    if (tx_insert(tx, &mld_employee) == 0) {
        printf("   ✓ Employee inserted successfully\n");
        
        // Process payroll (Business Process)
        process_monthly_payroll(fm, 1, 2024);  // Jan 2024
        
        // Generate reports
        generate_payroll_report(fm, 1, 2024);
        
        // Commit transaction
        if (tx_commit(tx) == 0) {
            printf("   ✓ Transaction committed\n");
        }
    }
    
    // Cleanup
    storage_close(fm);
    printf("\n=== MERISE Workflow Complete ===\n");
}

// ==================== PAYROLL PROCESSING ====================

void process_monthly_payroll(FileManager* fm, int month, int year) {
    printf("\nProcessing Payroll for %d-%d\n", year, month);
    
    // MERISE MCT: Payroll Process
    // 1. Collect attendance data
    // 2. Calculate earnings
    // 3. Calculate deductions
    // 4. Generate payslips
    // 5. Update balances
    
    ACIDTransaction* tx = tx_begin(ISOLATION_SERIALIZABLE);
    
    // For each active employee
    int employee_ids[1000];
    int emp_count = get_active_employees(fm, employee_ids, 1000);
    
    for (int i = 0; i < emp_count; i++) {
        // Calculate payroll
        PayrollRecord payroll = calculate_employee_payroll(
            fm, employee_ids[i], month, year);
        
        // Insert payroll record
        tx_insert_payroll(tx, &payroll);
        
        // Generate payslip
        generate_payslip(&payroll);
    }
    
    tx_commit(tx);
}

// ==================== MAIN FUNCTION ====================

int main(int argc, char* argv[]) {
    
    // Check command line arguments
    if (argc > 1) {
        if (strcmp(argv[1], "--merise-demo") == 0) {
            merise_workflow();
            return 0;
        }
        else if (strcmp(argv[1], "--process-payroll") == 0) {
            int month = atoi(argv[2]);
            int year = atoi(argv[3]);
            process_monthly_payroll(NULL, month, year);
            return 0;
        }
    }
    
    // Interactive mode
    printf("HR & Payroll Management System\n");
    printf("Built using MERISE Methodology\n\n");
    
    printf("Select mode:\n");
    printf("1. HR Administration\n");
    printf("2. Payroll Processing\n");
    printf("3. Employee Self-Service\n");
    printf("4. Reports & Analytics\n");
    printf("5. System Administration\n");
    
    int choice;
    scanf("%d", &choice);
    
    switch(choice) {
        case 1:
            hr_administration_mode();
            break;
        case 2:
            payroll_processing_mode();
            break;
        case 3:
            employee_self_service_mode();
            break;
        case 4:
            reporting_mode();
            break;
        case 5:
            system_admin_mode();
            break;
        default:
            printf("Invalid choice\n");
    }
    
    return 0;
}
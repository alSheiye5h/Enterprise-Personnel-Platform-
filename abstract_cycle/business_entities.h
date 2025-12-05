#ifndef BUSINESS_ENTITIES_H // if not defined to prevent multiple imports
#define BUSINESS_ENTITIES_H

#include <time.h>

// ================ CONCEPTUAL ENTITIES (MCD) ==================
// business representation

// MERISE MCD: Entity "Employee" with business attributes
typedef struct {
    // Business Identifier (Natural Key)
    char employee_code[20]; // format: HR-EMP-NNNN
    char cin[20]; // format: XXNNNNNN
    char passport_number[20]; // format: XXNNNNNN (for international employees)

    // Personal informations
    char first_name[50];
    char last_name[50];
    char middle_name[50];
    char gender; // format: M/F
    struct tm birth;
    char marital_status; // format: S/M/D
    int dependents_count; // for tax calculs

    // Contact Informations
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
    




}
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
    char first_name




}
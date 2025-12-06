erDiagram
    employe ||--o{ contrat_travail : "signe"
    employe ||--o{ fiche_paie : "reçoit"
    employe ||--o{ conge : "prend"
    employe ||--o{ pointage : "enregistre"
    employe ||--o{ document_employe : "possède"
    employe ||--o{ formation_employe : "suit"
    employe ||--o{ competence_employe : "possède"
    
    employe }o--o{ employe_departement : "affecté à"
    employe_departement }o--o{ departement : "comprend"
    
    contrat_travail ||--o{ fiche_paie : "génère"
    
    configuration_legale ||--o{ fiche_paie : "utilisée pour"
    configuration_legale ||--o{ declaration_cnss : "base de"
    
    declaration_cnss }o--o{ fiche_paie : "agrège"
    
    audit_conformite ||--o{ employe : "audite"
    audit_conformite ||--o{ contrat_travail : "vérifie"
    audit_conformite ||--o{ fiche_paie : "contrôle"
    audit_conformite ||--o{ document_employe : "inspecte"
    
    employe ||--o{ audit_conformite : "validé par"
    contrat_travail ||--o{ audit_conformite : "audité"
    
    employe {
        string code_employe PK
        string cin
        string prenom
        string nom
        string type_employe
        string statut_emploi
        date date_embauche
    }
    
    contrat_travail {
        int id_contrat PK
        string code_employe FK
        string type_contrat
        string statut_contrat
        decimal salaire_base_mensuel
    }
    
    fiche_paie {
        string id_paie PK
        string code_employe FK
        int mois_paie
        int annee_paie
        decimal salaire_brut
        decimal ir_calcule
    }
    
    conge {
        int id_conge PK
        string code_employe FK
        string type_conge
        string statut_demande
        date date_debut
        date date_fin
    }
    
    pointage {
        int id_pointage PK
        string code_employe FK
        date date_pointage
        time heure_arrivee
        time heure_depart
        boolean absence
    }
    
    declaration_cnss {
        int id_declaration PK
        string numero_declaration
        int mois_declaration
        int annee_declaration
        decimal total_salaires_bruts
        string statut
    }
    
    configuration_legale {
        int id_config PK
        string code_pays
        int annee_applicable
        decimal plafond_cnss
        decimal taux_cnss_employe
    }
    
    document_employe {
        int id_document PK
        string code_employe FK
        string type_document
        string nom_document
        boolean est_valide
        date date_expiration
    }
    
    formation_employe {
        int id_formation PK
        string code_employe FK
        string intitule_formation
        date date_debut
        date date_fin
    }
    
    competence_employe {
        string code_employe PK,FK
        string code_competence PK
        string nom_competence
        string niveau_maitrise
    }
    
    employe_departement {
        string code_employe PK,FK
        string code_departement PK
        date date_affectation PK
        decimal pourcentage_allocation
        boolean manager_departement
    }
    
    audit_conformite {
        int id_audit PK
        string type_audit
        date periode_audit_debut
        date periode_audit_fin
        integer nombre_anomalies
    }
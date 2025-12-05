erDiagram
    employe ||--o{ hierarchie_employe : "gère/est géré"
    employe ||--o{ paie : "reçoit"
    employe ||--o{ pointage : "enregistre"
    employe ||--o{ conge : "prend"
    employe ||--o{ contrat : "signe"
    employe }o--|| departement : "appartient à"
    employe }o--|| poste : "occupe"
    
    departement ||--o{ hierarchie_employe : "a des relations hiérarchiques"
    departement }o--o{ employe : "travaillent dans"
    departement ||--o{ departement : "hiérarchie"
    
    poste }o--o{ employe : "occupés par"
    
    employe ||--o{ employe : "auto-référence (hierarchie)"
    departement ||--o{ employe : "géré par"
    
    competence ||--o{ hierarchie_employe : "utilisée dans mentorat"
    competence }o--o{ employe : "possédées par"
    
    configuration_fiscale ||--o{ paie : "utilisée pour"
    
    formation }o--o{ employe : "suivies par"
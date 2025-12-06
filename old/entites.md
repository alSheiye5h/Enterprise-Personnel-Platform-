


### employe
- **code_employe** : VARCHAR(20) - Clé primaire
- **pays** : VARCHAR(50) - DEFAULT 'Maroc'
- **cin** : VARCHAR(20) - CIN obligatoire pour Marocains (12 caractères)
- **numero_passeport** : VARCHAR(20) - Passeport obligatoire pour étrangers
- **numero_immatriculation_cnss** : VARCHAR(20) - NOT NULL
- **date_immatriculation_cnss** : DATE - NOT NULL
- **numero_assure_amo** : VARCHAR(30)
- **statut_cotisation_cnss** : VARCHAR(20) - DEFAULT 'ACTIF'
  - Valeurs : 'ACTIF', 'SUSPENDU', 'RADIE'
- **prenom** : VARCHAR(50) - NOT NULL
- **nom** : VARCHAR(50) - NOT NULL
- **deuxieme_prenom** : VARCHAR(30)
- **sexe** : VARCHAR(1) - 'M' ou 'F'
- **date_naissance** : DATE - NOT NULL (≥ 18 ans)
- **lieu_naissance** : VARCHAR(100)
- **nationalite** : VARCHAR(50) - DEFAULT 'Marocaine'
- **situation_matrimoniale** : VARCHAR(20) - NOT NULL
  - Valeurs : 'MARIE', 'CELIBATAIRE', 'VEUF', 'DIVORCE'
- **nombre_enfants** : INTEGER - DEFAULT 0
- **nb_personnes_charge** : INTEGER - DEFAULT 0
- **email_personnel** : VARCHAR(100)
- **email_professionnel** : VARCHAR(100) - NOT NULL
- **telephone_mobile** : VARCHAR(20) - NOT NULL
- **telephone_domicile** : VARCHAR(20)
- **adresse_ligne1** : VARCHAR(100) - NOT NULL
- **adresse_ligne2** : VARCHAR(100)
- **ville** : VARCHAR(50) - NOT NULL
- **region** : VARCHAR(50) - NOT NULL
- **code_postal** : VARCHAR(20) - NOT NULL
- **nom_contact_urgence** : VARCHAR(100) - NOT NULL
- **telephone_contact_urgence** : VARCHAR(20) - NOT NULL
- **relation_contact_urgence** : VARCHAR(30) - NOT NULL
- **rib** : VARCHAR(34) - NOT NULL UNIQUE (≥ 24 caractères)
- **nom_banque** : VARCHAR(50) - NOT NULL
- **agence_bancaire** : VARCHAR(50)
- **type_employe** : VARCHAR(20) - NOT NULL
  - Valeurs : 'CADRE', 'EMPLOYE', 'OUVRIER', 'DIRIGEANT'
- **categorie_professionnelle** : VARCHAR(50)
  - Valeurs : 'CATEGORIE 1', 'CATEGORIE 2', 'CATEGORIE 3', 'CATEGORIE 4', 'CATEGORIE 5'
- **coefficient_hierarchique** : DECIMAL(5,2)
- **matricule_interne** : VARCHAR(20) - UNIQUE
- **code_etablissement** : VARCHAR(20) - NOT NULL
- **code_unite_organisationnelle** : VARCHAR(20)
- **dossier_complet** : BOOLEAN - DEFAULT FALSE
- **date_verification_dossier** : DATE
- **verificateur_dossier** : VARCHAR(20)
- **photocopie_cin_valide** : BOOLEAN - DEFAULT FALSE
- **rib_verifie** : BOOLEAN - DEFAULT FALSE
- **attestation_cnss_valide** : BOOLEAN - DEFAULT FALSE
- **diplomes_verifies** : BOOLEAN - DEFAULT FALSE
- **visite_medicale_valide** : BOOLEAN - DEFAULT FALSE
- **contrat_signe** : BOOLEAN - DEFAULT FALSE
- **statut_emploi** : VARCHAR(20) - DEFAULT 'ACTIF'
  - Valeurs : 'ACTIF', 'CONGE', 'SUSPENDU', 'LICENCIE', 'DEMISSIONNAIRE', 'RETRAITE'
- **date_embauche** : DATE - NOT NULL
- **date_fin_periode_essai** : DATE
- **date_depart** : DATE
- **motif_depart** : VARCHAR(100)
- **date_creation** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **date_modification** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **createur** : VARCHAR(50)
- **modificateur** : VARCHAR(50)

---

### contrat_travail
- **id_contrat** : SERIAL - Clé primaire
- **code_employe** : VARCHAR(20) - Référence à employe
- **type_contrat** : VARCHAR(30) - NOT NULL
  - Valeurs : 'CDI', 'CDD', 'CONTRAT_MISSION', 'CONTRAT_INTERIMAIRE', 'STAGE'
- **motif_cdd** : VARCHAR(100) - Obligatoire pour CDD
- **date_debut_contrat** : DATE - NOT NULL
- **date_fin_contrat** : DATE - (≤ 24 mois pour CDD)
- **date_signature** : DATE - NOT NULL
- **date_effet** : DATE - NOT NULL
- **periode_essai_jours** : INTEGER - NOT NULL (0-180 jours)
- **periode_essai_renouvelable** : BOOLEAN - DEFAULT FALSE
- **date_fin_periode_essai** : DATE
- **salaire_base_mensuel** : DECIMAL(10,2) - NOT NULL
- **heures_hebdomadaires** : INTEGER - NOT NULL
- **salaire_horaire** : DECIMAL(8,2)
- **devise** : VARCHAR(3) - DEFAULT 'MAD'
- **heures_journalieres** : INTEGER (1-10)
- **jours_travail_semaine** : INTEGER (1-6)
- **regime_horaire** : VARCHAR(30)
  - Valeurs : 'JOUR', 'NUIT', 'ALTERNANT', 'POSTES'
- **jours_conges_acquis** : DECIMAL(5,2) - DEFAULT 1.5
- **jours_conges_prise** : DECIMAL(5,2) - DEFAULT 0
- **solde_conges** : DECIMAL(5,2)
- **prime_anciennete** : BOOLEAN - DEFAULT FALSE
- **taux_prime_anciennete** : DECIMAL(5,2) (0-100)
- **assurance_sante** : BOOLEAN - DEFAULT TRUE
- **retraite_complementaire** : BOOLEAN - DEFAULT FALSE
- **mutuelle_entreprise** : BOOLEAN - DEFAULT FALSE
- **tickets_restaurant** : BOOLEAN - DEFAULT FALSE
- **valeur_ticket_restaurant** : DECIMAL(5,2)
- **preavis_depart_jours** : INTEGER - NOT NULL (≥ 8 jours)
- **indemnite_licenciement_calcul** : VARCHAR(50)
- **indemnite_preavis_calcul** : VARCHAR(50)
- **chemin_contrat_pdf** : VARCHAR(255)
- **chemin_annexes** : VARCHAR(255)
- **contrat_bilingue** : BOOLEAN - DEFAULT TRUE
- **version_contrat** : INTEGER - DEFAULT 1
- **statut_contrat** : VARCHAR(20) - DEFAULT 'ACTIF'
  - Valeurs : 'ACTIF', 'SUSPENDU', 'RESILIE', 'ACHEVE', 'RUPTURE'
- **motif_rupture** : VARCHAR(100)
- **date_creation** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **date_modification** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **createur** : VARCHAR(50)
- **modificateur** : VARCHAR(50)

---

### fiche_paie 
- **id_paie** : VARCHAR(30) - Clé primaire
- **code_employe** : VARCHAR(20) - Référence à employe
- **mois_paie** : INTEGER - NOT NULL (1-12)
- **annee_paie** : INTEGER - NOT NULL (≥ 2020)
- **periode_debut** : DATE - NOT NULL
- **periode_fin** : DATE - NOT NULL
- **date_etablissement** : DATE - DEFAULT CURRENT_DATE
- **date_paiement** : DATE - NOT NULL
- **salaire_base** : DECIMAL(10,2) - NOT NULL
- **heures_normales** : DECIMAL(6,2) - DEFAULT 191
- **heures_supp_25** : DECIMAL(6,2) - DEFAULT 0
- **heures_supp_50** : DECIMAL(6,2) - DEFAULT 0
- **heures_supp_100** : DECIMAL(6,2) - DEFAULT 0
- **prime_anciennete** : DECIMAL(10,2) - DEFAULT 0
- **prime_panier** : DECIMAL(10,2) - DEFAULT 0
- **prime_transport** : DECIMAL(10,2) - DEFAULT 0
- **prime_logement** : DECIMAL(10,2) - DEFAULT 0
- **prime_presence** : DECIMAL(10,2) - DEFAULT 0
- **prime_performance** : DECIMAL(10,2) - DEFAULT 0
- **commission** : DECIMAL(10,2) - DEFAULT 0
- **autres_primes** : DECIMAL(10,2) - DEFAULT 0
- **allocation_familiale** : DECIMAL(10,2) - DEFAULT 0
- **salaire_brut** : DECIMAL(10,2)
- **assiette_cnss** : DECIMAL(10,2)
- **taux_cnss_employe** : DECIMAL(5,4) - DEFAULT 0.0426
- **taux_cnss_employeur** : DECIMAL(5,4) - DEFAULT 0.0874
- **cotisation_cnss_employe** : DECIMAL(10,2)
- **cotisation_cnss_employeur** : DECIMAL(10,2)
- **assiette_amo** : DECIMAL(10,2)
- **taux_amo_employe** : DECIMAL(5,4) - DEFAULT 0.0226
- **taux_amo_employeur** : DECIMAL(5,4) - DEFAULT 0.0339
- **cotisation_amo_employe** : DECIMAL(10,2)
- **cotisation_amo_employeur** : DECIMAL(10,2)
- **revenu_net_imposable** : DECIMAL(10,2)
- **deduction_forfaitaire** : DECIMAL(10,2) - DEFAULT 0
- **abattement_20** : DECIMAL(10,2)
- **revenu_imposable** : DECIMAL(10,2)
- **ir_calcule** : DECIMAL(10,2)
- **retenue_pret** : DECIMAL(10,2) - DEFAULT 0
- **avance_salaire** : DECIMAL(10,2) - DEFAULT 0
- **autres_retenues** : DECIMAL(10,2) - DEFAULT 0
- **total_cotisations** : DECIMAL(10,2)
- **total_a_payer** : DECIMAL(10,2)
- **net_a_payer** : DECIMAL(10,2)
- **mode_paiement** : VARCHAR(20) - NOT NULL
  - Valeurs : 'VIREMENT', 'CHEQUE', 'ESPECES'
- **numero_virement** : VARCHAR(50)
- **statut_paiement** : VARCHAR(20) - DEFAULT 'A_PAYER'
  - Valeurs : 'A_PAYER', 'PAYE', 'ANNULE', 'RETARD'
- **numero_bulletin_cnss** : VARCHAR(30)
- **numero_declaration_fiscale** : VARCHAR(30)
- **date_declaration_cnss** : DATE
- **date_declaration_fiscale** : DATE
- **valide_par** : VARCHAR(50)
- **date_validation** : DATE
- **paiement_effectue_par** : VARCHAR(50)
- **date_paiement_effectif** : DATE
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **updated_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP

---

### declaration_cnss 
- **id_declaration** : SERIAL - Clé primaire
- **numero_declaration** : VARCHAR(30) - UNIQUE
- **mois_declaration** : INTEGER - NOT NULL (1-12)
- **annee_declaration** : INTEGER - NOT NULL
- **date_declaration** : DATE - NOT NULL
- **date_limite** : DATE - NOT NULL
- **total_salaires_bruts** : DECIMAL(12,2) - NOT NULL
- **total_assiette_cnss** : DECIMAL(12,2) - NOT NULL
- **total_cotisations_employe** : DECIMAL(12,2) - NOT NULL
- **total_cotisations_employeur** : DECIMAL(12,2) - NOT NULL
- **total_cotisations_amo_employe** : DECIMAL(12,2) - NOT NULL
- **total_cotisations_amo_employeur** : DECIMAL(12,2) - NOT NULL
- **total_general** : DECIMAL(12,2) - NOT NULL
- **statut** : VARCHAR(20) - DEFAULT 'BROUILLON'
  - Valeurs : 'BROUILLON', 'VALIDEE', 'TRANSMISE', 'ACCEPTEE', 'REJETEE'
- **date_transmission** : DATE
- **date_acceptation** : DATE
- **reference_acceptation** : VARCHAR(50)
- **fichier_declaration** : VARCHAR(255)
- **fichier_quittance** : VARCHAR(255)
- **observations** : TEXT
- **declare_par** : VARCHAR(50) - NOT NULL
- **verifie_par** : VARCHAR(50)
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **updated_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP

---

### conge 
- **id_conge** : SERIAL - Clé primaire
- **code_employe** : VARCHAR(20) - Référence à employe
- **type_conge** : VARCHAR(30) - NOT NULL
  - Valeurs : 'CONGE_ANNUEL', 'CONGE_MALADIE', 'CONGE_MATERNITE', 'CONGE_PATERNITE', 'CONGE_EXCEPTIONNEL', 'CONGE_SANS_SOLDE'
- **date_debut** : DATE - NOT NULL
- **date_fin** : DATE - NOT NULL
- **date_demande** : DATE - DEFAULT CURRENT_DATE
- **jours_ouvrables** : DECIMAL(5,2) - NOT NULL
- **jours_calendaires** : DECIMAL(5,2)
- **certificat_medical_maternite** : VARCHAR(100)
- **date_accouchement** : DATE
- **certificat_medical** : VARCHAR(100)
- **maladie_professionnelle** : BOOLEAN - DEFAULT FALSE
- **statut_demande** : VARCHAR(20) - DEFAULT 'EN_ATTENTE'
  - Valeurs : 'EN_ATTENTE', 'APPROUVE', 'REJETE', 'ANNULE'
- **approbateur** : VARCHAR(20)
- **date_approbation** : DATE
- **motif_rejet** : VARCHAR(200)
- **solde_conge_avant** : DECIMAL(5,2) - NOT NULL
- **solde_conge_apres** : DECIMAL(5,2)
- **deduction_salaire** : DECIMAL(10,2) - DEFAULT 0
- **pris_en_compte_paie** : BOOLEAN - DEFAULT FALSE
- **conge_paye** : BOOLEAN
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **updated_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP

---

### pointage 
- **id_pointage** : SERIAL - Clé primaire
- **code_employe** : VARCHAR(20) - Référence à employe
- **date_pointage** : DATE - NOT NULL
- **jour_semaine** : VARCHAR(10)
- **est_jour_ferie** : BOOLEAN - DEFAULT FALSE
- **est_weekend** : BOOLEAN
- **heure_debut_theorique** : TIME - NOT NULL
- **heure_fin_theorique** : TIME - NOT NULL
- **pause_debut** : TIME
- **pause_fin** : TIME
- **heure_arrivee** : TIME
- **heure_depart** : TIME
- **pointage_entree_valide** : BOOLEAN - DEFAULT FALSE
- **pointage_sortie_valide** : BOOLEAN - DEFAULT FALSE
- **heures_theoriques** : DECIMAL(4,2)
- **heures_reelles** : DECIMAL(4,2)
- **retard_minutes** : INTEGER
- **heures_supp_25** : DECIMAL(4,2) - DEFAULT 0
- **heures_supp_50** : DECIMAL(4,2) - DEFAULT 0
- **heures_supp_100** : DECIMAL(4,2) - DEFAULT 0
- **absence** : BOOLEAN - DEFAULT FALSE
- **type_absence** : VARCHAR(30)
  - Valeurs : 'MALADIE', 'CONGE', 'AUTORISATION', 'NON_JUSTIFIEE'
- **justificatif_absence** : VARCHAR(100)
- **statut_pointage** : VARCHAR(20) - DEFAULT 'SAISI'
  - Valeurs : 'SAISI', 'CORRIGE', 'VALIDE', 'REJETE'
- **validateur** : VARCHAR(20)
- **date_validation** : DATE
- **observations** : TEXT
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **updated_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP

---

## Tables de Configuration et de Liens

### configuration_legale 
- **id_config** : SERIAL - Clé primaire
- **code_pays** : VARCHAR(5) - DEFAULT 'MA'
- **annee_applicable** : INTEGER - NOT NULL
- **date_debut_validite** : DATE - NOT NULL
- **date_fin_validite** : DATE
- **smig_industriel** : DECIMAL(10,2) - NOT NULL
- **smig_commercial** : DECIMAL(10,2) - NOT NULL
- **smig_agricole** : DECIMAL(10,2) - NOT NULL
- **date_maj_smig** : DATE - NOT NULL
- **bareme_ir** : JSONB - NOT NULL
- **deduction_forfaitaire** : DECIMAL(10,2) - NOT NULL
- **abattement_taux** : DECIMAL(5,4) - DEFAULT 0.20
- **plafond_cnss** : DECIMAL(10,2) - DEFAULT 6000
- **taux_cnss_employe** : DECIMAL(5,4) - NOT NULL
- **taux_cnss_employeur** : DECIMAL(5,4) - NOT NULL
- **taux_allocation_familiale** : DECIMAL(5,4)
- **montant_allocation_familiale** : DECIMAL(10,2) - DEFAULT 150
- **taux_amo_employe** : DECIMAL(5,4) - NOT NULL
- **taux_amo_employeur** : DECIMAL(5,4) - NOT NULL
- **plafond_amo** : DECIMAL(10,2)
- **taux_cimr_employe** : DECIMAL(5,4)
- **taux_cimr_employeur** : DECIMAL(5,4)
- **plafond_cimr** : DECIMAL(10,2)
- **taux_hsup_25** : DECIMAL(5,4) - DEFAULT 0.25
- **taux_hsup_50** : DECIMAL(5,4) - DEFAULT 0.50
- **taux_hsup_100** : DECIMAL(5,4) - DEFAULT 1.00
- **limite_mensuelle_hsup** : DECIMAL(6,2) - DEFAULT 20
- **taux_acquisition_conges** : DECIMAL(5,2) - DEFAULT 1.5
- **duree_conge_maternite_jours** : INTEGER - DEFAULT 98
- **duree_conge_paternite_jours** : INTEGER - DEFAULT 3
- **delai_declaration_cnss_jours** : INTEGER - DEFAULT 10
- **delai_paiement_salaire_jours** : INTEGER - DEFAULT 15
- **source_officielle** : VARCHAR(255)
- **reference_juridique** : VARCHAR(100)
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP
- **created_by** : VARCHAR(50)

---

### employe_departement 
- **code_employe** : VARCHAR(20) - Référence à employe
- **code_departement** : VARCHAR(20) - NOT NULL
- **date_affectation** : DATE - DEFAULT CURRENT_DATE
- **date_fin_affectation** : DATE
- **pourcentage_allocation** : DECIMAL(5,2) - NOT NULL (0-100%)
- **manager_departement** : BOOLEAN - DEFAULT FALSE
- **statut_affectation** : VARCHAR(20) - DEFAULT 'ACTIVE'
  - Valeurs : 'ACTIVE', 'HISTORIQUE', 'FUTURE'
- **Clé primaire** : (code_employe, code_departement, date_affectation)

---

### formation_employe 
- **id_formation** : SERIAL - Clé primaire
- **code_employe** : VARCHAR(20) - Référence à employe
- **intitule_formation** : VARCHAR(200) - NOT NULL
- **type_formation** : VARCHAR(50) - NOT NULL
- **organisme_formateur** : VARCHAR(100)
- **date_debut** : DATE - NOT NULL
- **date_fin** : DATE - NOT NULL
- **duree_heures** : INTEGER - NOT NULL
- **cout_formation** : DECIMAL(10,2)
- **prise_en_charge_entreprise** : DECIMAL(5,2) - DEFAULT 100
- **certification_obtenue** : BOOLEAN - DEFAULT FALSE
- **nom_certification** : VARCHAR(100)
- **valide_par** : VARCHAR(50)
- **notes** : TEXT
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP

---

### competence_employe 
- **code_employe** : VARCHAR(20) - Référence à employe
- **code_competence** : VARCHAR(20) - NOT NULL
- **nom_competence** : VARCHAR(100) - NOT NULL
- **niveau_maitrise** : VARCHAR(20)
  - Valeurs : 'DEBUTANT', 'INTERMEDIAIRE', 'AVANCE', 'EXPERT'
- **date_acquisition** : DATE - NOT NULL
- **date_expiration** : DATE
- **certifie_par** : VARCHAR(50)
- **organisme_certificateur** : VARCHAR(100)
- **Clé primaire** : (code_employe, code_competence)

---

### document_employe
- **id_document** : SERIAL - Clé primaire
- **code_employe** : VARCHAR(20) - Référence à employe
- **type_document** : VARCHAR(50) - NOT NULL
  - Valeurs : 'CIN', 'PASSEPORT', 'RIB', 'DIPLOME', 'ATTESTATION_CNSS', 'VISITE_MEDICALE', 'CONTRAT', 'CERTIFICAT_TRAVAIL', 'AUTRE'
- **nom_document** : VARCHAR(100) - NOT NULL
- **chemin_fichier** : VARCHAR(255) - NOT NULL
- **date_emission** : DATE
- **date_expiration** : DATE
- **est_valide** : BOOLEAN - DEFAULT TRUE
- **date_validation** : DATE
- **validateur** : VARCHAR(50)
- **observations** : TEXT
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP

---

### audit_conformite 
- **id_audit** : SERIAL - Clé primaire
- **type_audit** : VARCHAR(50) - NOT NULL
  - Valeurs : 'PAIE', 'CNSS', 'CONTRAT', 'DOCUMENTS', 'TEMPS_TRAVAIL'
- **periode_audit_debut** : DATE - NOT NULL
- **periode_audit_fin** : DATE - NOT NULL
- **date_audit** : DATE - DEFAULT CURRENT_DATE
- **nombre_anomalies** : INTEGER - DEFAULT 0
- **anomalies_critiques** : INTEGER - DEFAULT 0
- **anomalies_majeures** : INTEGER - DEFAULT 0
- **anomalies_mineures** : INTEGER - DEFAULT 0
- **taux_conformite** : DECIMAL(5,2)
- **observations** : TEXT
- **recommandations** : TEXT
- **plan_action** : TEXT
- **auditeur** : VARCHAR(50) - NOT NULL
- **valide_par** : VARCHAR(50)
- **date_validation** : DATE
- **created_at** : TIMESTAMP - DEFAULT CURRENT_TIMESTAMP




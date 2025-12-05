# Entités du Système de Gestion des Ressources Humaines

## employe
- **code_employe** (PK) : varchar(20) - Identifiant interne (ex: HR-EMP-001)
- **cin** : varchar(20) - Numéro CIN / sécurité sociale
- **numero_passeport** : varchar(20) - Numéro de passeport (pour internationaux)
- **numero_immatriculation_cnss** : varchar(20) - Numéro d'immatriculation CNSS
- **prenom** : varchar(50) - Prénom principal
- **nom** : varchar(50) - Nom de famille
- **deuxieme_prenom** : varchar(30) - 2ème prénom (optionnel)
- **sexe** : char(1) - Sexe (M/F/O)
- **date_naissance** : date - Date de naissance
- **situation_matrimoniale** : varchar(15) - Statut matrimonial
- **nb_personnes_charge** : integer - Nombre de personnes à charge
- **email_personnel** : varchar(100) - Email personnel
- **email_professionnel** : varchar(100) - Email professionnel
- **telephone_mobile** : varchar(20) - Téléphone mobile
- **telephone_domicile** : varchar(20) - Téléphone fixe domicile
- **adresse_ligne1** : varchar(100) - Adresse ligne 1
- **adresse_ligne2** : varchar(100) - Adresse ligne 2 (complément)
- **ville** : varchar(50) - Ville
- **region** : varchar(50) - Région/État
- **code_postal** : varchar(20) - Code postal
- **pays** : varchar(50) - Pays
- **nom_contact_urgence** : varchar(100) - Nom du contact d'urgence
- **telephone_contact_urgence** : varchar(20) - Téléphone contact d'urgence
- **relation_contact_urgence** : varchar(30) - Lien familial du contact
- **code_departement** : varchar(20) - Référence département
- **code_poste** : varchar(20) - Référence poste
- **statut_emploi** : varchar(20) - Statut emploi (actif, congé, parti)
- **date_embauche** : date - Date d'embauche
- **date_fin_periode_essai** : date - Fin période d'essai
- **date_depart** : date - Date de départ
- **raison_depart** : varchar(50) - Motif de départ
- **contrat_signe** : boolean - Contrat signé
- **verification_antecedents** : boolean - Vérification antécédents
- **verifie** : boolean - Dossier complet
- **est_valide** : boolean - Actif et conforme

## hierarchie_employe
- **id** (PK) : integer - Identifiant unique auto-incrémenté
- **code_employe** : varchar(20) - Référence employé
- **code_manager** : varchar(20) - Référence manager
- **type_relation** : varchar(30) - Type de relation hiérarchique
- **code_departement** : varchar(20) - Référence département
- **code_projet** : varchar(20) - Code projet (si relation projet)
- **code_competence** : varchar(20) - Référence compétence (si mentorat)
- **date_debut** : date - Date début relation
- **date_fin** : date - Date fin relation
- **niveau_relation** : integer - Niveau relation (1=direct, 2=indirect...)
- **poids_decision** : decimal(5,2) - Poids dans les décisions
- **scope_relation** : varchar(20) - Périmètre relation
- **domaines_autorises** : json - Domaines d'autorité
- **statut_relation** : varchar(20) - Statut relation
- **approuvee_par** : varchar(20) - Approuvé par
- **date_approbation** : date - Date approbation
- **date_creation** : timestamp - Date création
- **commentaires** : text - Commentaires

## departement
- **code_departement** (PK) : varchar(20) - Code département (ex: DEP-IT)
- **nom_departement** : varchar(100) - Nom complet département
- **type_departement** : varchar(30) - Type (fonctionnel, projet...)
- **code_centre_cout** : varchar(20) - Code centre de coût
- **code_localisation** : varchar(20) - Lieu géographique
- **code_manager** : varchar(20) - Responsable département
- **date_creation** : date - Date création
- **budget_annuel** : decimal(12,2) - Budget annuel
- **effectif_approuve** : integer - Headcount approuvé
- **effectif_actuel** : integer - Effectif réel
- **code_departement_parent** : varchar(20) - Département parent
- **niveau_hierarchique** : integer - Niveau dans l'arbre

## poste
- **code_poste** (PK) : varchar(20) - Code poste (ex: JOB-DEV-001)
- **intitule_poste** : varchar(100) - Intitulé officiel
- **famille_metier** : varchar(50) - Famille métier
- **grade_poste** : varchar(10) - Grade (G7, G8...)
- **categorie_eeo** : varchar(10) - Classification EEO
- **salaire_minimum** : decimal(10,2) - Plancher salarial
- **salaire_median** : decimal(10,2) - Médian salarial
- **salaire_maximum** : decimal(10,2) - Plafond salarial
- **devise** : varchar(5) - Devise (EUR, USD...)
- **annees_experience_requises** : integer - Années expérience requises
- **niveau_education** : varchar(50) - Niveau études
- **certifications_requises** : text - Certifications obligatoires

## paie
- **id_paie** (PK) : varchar(30) - Identifiant paie (ex: PAY-2024-01-EMP001)
- **code_employe** : varchar(20) - Référence employé
- **periode_debut** : date - Période début
- **periode_fin** : date - Période fin
- **date_paiement** : date - Date paiement
- **salaire_base** : decimal(10,2) - Salaire base
- **allocation_logement** : decimal(10,2) - Allocation logement
- **allocation_transport** : decimal(10,2) - Allocation transport
- **heures_supplementaires** : decimal(10,2) - Heures supplémentaires
- **prime_performance** : decimal(10,2) - Prime performance
- **commission** : decimal(10,2) - Commission
- **autres_allocations** : decimal(10,2) - Autres allocations
- **total_gains** : decimal(10,2) - Total gains
- **impot_revenu** : decimal(10,2) - Impôt sur le revenu
- **cotisation_cnss_employe** : decimal(10,2) - Cotisation CNSS employé
- **cotisation_cnss_employeur** : decimal(10,2) - Cotisation CNSS employeur
- **assurance_sante_AMO** : decimal(10,2) - Assurance santé AMO
- **cotisation_retraite** : decimal(10,2) - Cotisation retraite
- **retenues_prets** : decimal(10,2) - Retenues prêts
- **autres_deductions** : decimal(10,2) - Autres déductions
- **total_deductions** : decimal(10,2) - Total déductions
- **salaire_net** : decimal(10,2) - Salaire net
- **mode_paiement** : varchar(20) - Mode paiement
- **numero_compte_bancaire** : varchar(30) - Numéro compte bancaire
- **nom_banque** : varchar(50) - Nom banque
- **statut_paiement** : varchar(20) - Statut paiement
- **numero_certificat_fiscal** : varchar(30) - Numéro certificat fiscal
- **declaration_fiscale_deposee** : boolean - Déclaration fiscale déposée

## pointage
- **id_pointage** (PK) : varchar(30) - Identifiant pointage
- **code_employe** : varchar(20) - Référence employé
- **date** : date - Date pointage
- **heure_debut_prevue** : timestamp - Heure début prévue
- **heure_fin_prevue** : timestamp - Heure fin prévue
- **heure_debut_reelle** : timestamp - Heure début réelle
- **heure_fin_reelle** : timestamp - Heure fin réelle
- **heures_programmees** : decimal(4,2) - Heures programmées
- **heures_reelles** : decimal(4,2) - Heures réelles
- **heures_normales** : decimal(4,2) - Heures normales
- **heures_supplementaires** : decimal(4,2) - Heures supplémentaires
- **heures_nuit** : decimal(4,2) - Heures nuit
- **heures_jours_feries** : decimal(4,2) - Heures jours fériés
- **statut_presence** : varchar(20) - Statut présence
- **code_shift** : varchar(20) - Code shift
- **statut_approbation** : varchar(20) - Statut approbation
- **code_approbateur** : varchar(20) - Code approbateur
- **remarques** : varchar(200) - Remarques

## conge
- **id_conge** (PK) : varchar(30) - Identifiant congé
- **code_employe** : varchar(20) - Référence employé
- **type_conge** : varchar(30) - Type congé
- **date_debut** : date - Date début
- **date_fin** : date - Date fin
- **total_jours** : decimal(5,2) - Total jours
- **statut_demande** : varchar(20) - Statut demande
- **date_demande** : date - Date demande
- **date_approbation** : date - Date approbation
- **code_approbateur** : varchar(20) - Code approbateur
- **jours_deduits** : decimal(5,2) - Jours déduits
- **chemin_document_justificatif** : varchar(200) - Chemin document justificatif
- **est_medical** : boolean - Congé médical
- **numero_certificat_medical** : varchar(30) - Numéro certificat médical
- **est_conge_paye** : boolean - Congé payé

## contrat
- **id_contrat** (PK) : varchar(30) - Identifiant contrat
- **code_employe** : varchar(20) - Référence employé
- **type_contrat** : varchar(30) - Type contrat
- **date_debut** : date - Date début
- **date_fin** : date - Date fin
- **date_signature** : date - Date signature
- **salaire_base** : decimal(10,2) - Salaire base
- **devise_salaire** : varchar(5) - Devise salaire
- **heures_par_semaine** : integer - Heures par semaine
- **periode_essai_jours** : integer - Période essai (jours)
- **preavis_jours** : integer - Préavis (jours)
- **assurance_sante** : boolean - Assurance santé
- **retraite** : boolean - Retraite
- **stock_options** : boolean - Stock options
- **jours_conges_annuels** : decimal(5,2) - Jours congés annuels
- **jours_conges_maladie** : decimal(5,2) - Jours congés maladie
- **chemin_contrat** : varchar(200) - Chemin contrat
- **chemin_copie_signee** : varchar(200) - Chemin copie signée
- **signature_numerique** : boolean - Signature numérique

## configuration_fiscale
- **code_pays** (PK) : varchar(5) - Code pays
- **annee_fiscale** : integer - Année fiscale
- **brackets** : json - Tranches fiscales
- **nombre_tranches** : integer - Nombre tranches
- **allocation_personnelle** : decimal(10,2) - Allocation personnelle
- **allocation_marie** : decimal(10,2) - Allocation marié
- **allocation_personne_charge** : decimal(10,2) - Allocation personne charge
- **taux_employe** : decimal(5,4) - Taux employé
- **taux_employeur** : decimal(5,4) - Taux employeur
- **plafond_cotisation** : decimal(10,2) - Plafond cotisation
- **code_formulaire_fiscal** : varchar(20) - Code formulaire fiscal
- **date_limite_declaration** : date - Date limite déclaration

## competence
- **code_competence** (PK) : varchar(20) - Code compétence
- **nom_competence** : varchar(100) - Nom compétence
- **categorie** : varchar(50) - Catégorie
- **niveau** : varchar(20) - Niveau
- **date_certification** : date - Date certification
- **organisme_certificateur** : varchar(100) - Organisme certificateur
- **date_expiration** : date - Date expiration
- **duree_validite_mois** : integer - Durée validité (mois)

## formation
- **id_formation** (PK) : varchar(30) - Identifiant formation
- **intitule_formation** : varchar(200) - Intitulé formation
- **type_formation** : varchar(50) - Type formation
- **date_debut** : date - Date début
- **date_fin** : date - Date fin
- **duree_heures** : integer - Durée heures
- **cout** : decimal(10,2) - Coût
- **prestataire** : varchar(100) - Prestataire
- **lieu** : varchar(100) - Lieu
- **nb_participants** : integer - Nombre participants
- **statut** : varchar(20) - Statut

## Tables de relation

### travaille_dans
- **code_employe** (PK) : varchar(20) - Référence employé
- **code_departement** (PK) : varchar(20) - Référence département
- **date_affectation** : date - Date affectation
- **type_affectation** : varchar(30) - Type affectation
- **pourcentage_allocation** : decimal(5,2) - Pourcentage allocation

### occupe_poste
- **code_employe** (PK) : varchar(20) - Référence employé
- **code_poste** (PK) : varchar(20) - Référence poste
- **date_effet** : date - Date effet
- **date_fin** : date - Date fin
- **niveau_grade** : varchar(10) - Niveau grade

### possede_competence
- **code_employe** (PK) : varchar(20) - Référence employé
- **code_competence** (PK) : varchar(20) - Référence compétence
- **niveau_maitrise** : varchar(20) - Niveau maîtrise
- **date_certification** : date - Date certification
- **certifie_par** : varchar(50) - Certifié par (référence employé)
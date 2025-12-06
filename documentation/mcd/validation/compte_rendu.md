# Documentation Technique - Système RH Marocain Conforme

### Version
**2.0** - Conformité totale avec la législation marocaine

### Technologies
- **PostgreSQL 12+**
  - Support des colonnes générées (GENERATED ALWAYS AS)
  - JSONB pour les configurations flexibles
  - Contraintes CHECK complexes pour la validation légale

--- 

## Architecture des Tables

### 1. Table Principale : `employe`

#### Sections Clés :
- **Identifiants** : Code unique généré automatiquement (MA-EMP-XXXXXX pour Marocains, INT-EMP-XXXXXX pour étrangers)
- **Documents légaux** : CIN (12 chiffres pour Marocains), passeport (obligatoire pour étrangers)
- **CNSS/AMO** : Numéros d'immatriculation obligatoires
- **Informations personnelles** : Validations d'âge (≥18 ans), nationalité cohérente
- **Coordonnées** : Adresse complète pour déclarations légales
- **Bancaire** : RIB marocain obligatoire pour virement
- **Conformité** : Suivi des documents obligatoires (CIN, diplômes, visite médicale, etc.)

#### Validations Automatiques :
```sql
-- Âge minimum 18 ans (Code du Travail Art. 143)
date_naissance <= CURRENT_DATE - INTERVAL '18 years'

-- CIN obligatoire pour Marocains (12 chiffres)
(pays = 'Maroc' AND cin IS NOT NULL AND LENGTH(cin) = 12)

-- Passeport obligatoire pour étrangers
(pays != 'Maroc' AND numero_passeport IS NOT NULL)

-- Nationalité cohérente avec le pays
(pays = 'Maroc' AND nationalite = 'Marocaine') OR
(pays != 'Maroc' AND nationalite != 'Marocaine')
```

---

### 2. Table : `contrat_travail`


#### Conformité Légale :
- **Types de contrats** : CDI, CDD (durée max 24 mois), mission, intérim, stage
- **Période d'essai** : Max 90 jours (non-cadres) ou 180 jours (cadres) - Art. 14
- **Temps de travail** : Max 44h/semaine - Art. 184
- **Congés payés** : 1.5 jours ouvrables/mois travaillé - Art. 234
- **Préavis** : Minimum selon ancienneté (8, 30 ou 60 jours) - Art. 62
- **SMIG/SMAG** : Salaire minimum vérifié automatiquement

#### Calculs Automatiques :
```sql
-- Salaire horaire calculé
salaire_horaire = (salaire_base_mensuel * 12) / (52 * heures_hebdomadaires)

-- Solde de congés
solde_conges = jours_conges_acquis - jours_conges_prise
```

---

### 3. Table : `fiche_paie`


#### Calculs Légaux Intégrés :

| Élément | Calcul | Référence Légale |
|---------|--------|------------------|
| Salaire brut | Base + heures supp + primes + allocations | - |
| Assiette CNSS | Plafonnée à 6,000 MAD | Règle pratique CNSS |
| Cotisation CNSS employé | 4.26% de l'assiette | Taux officiel |
| Cotisation CNSS employeur | 8.74% de l'assiette | Taux officiel |
| Cotisation AMO employé | 2.26% du brut | Taux AMO 2024 |
| Cotisation AMO employeur | 3.39% du brut | Taux AMO 2024 |
| Allocation familiale | 150 MAD/personne à charge | Barème CNSS |
| IR | Barème progressif automatique | Barème DGI |

#### Barème IR Automatique :
```sql
CASE
    WHEN revenu_imposable <= 2500 THEN 0
    WHEN revenu_imposable <= 4166.66 THEN ROUND((revenu_imposable - 2500) * 0.10, 2) -- ROUND function to ensure that the value rendred is decimal with 2 apres virgule
    WHEN revenu_imposable <= 5000 THEN ROUND(166.67 + (revenu_imposable - 4166.67) * 0.20, 2)
    WHEN revenu_imposable <= 6666.66 THEN ROUND(333.33 + (revenu_imposable - 5000.00) * 0.30, 2)
    WHEN revenu_imposable <= 10000 THEN ROUND(833.33 + (revenu_imposable - 6666.67) * 0.34, 2)
    ELSE ROUND(1966.67 + (revenu_imposable - 10000.00) * 0.38, 2)
END 
```

---

### 4. Table : `declaration_cnss`

#### Caractéristiques :
- Génération automatique du numéro : **DCNSS-YYYYMM-XXXX** (code document pour chaque declaration)
- Suivi des dates limites (généralement le 10 du mois suivant)
- Totaux pré-calculés pour validation
- **Workflow** : Brouillon → Validée → Transmise → Acceptée

---

### 5. Table : `conge`


#### Types de Congés Gérés :
- **Congé annuel** : 1.5 jours/mois travaillé
- **Congé maladie** : Justificatif obligatoire > 4 jours
- **Congé maternité** : 14 semaines (98 jours)
- **Congé paternité** : 3 jours
- **Congé exceptionnel** : Sans solde

#### Validations :
```sql
# Conge maternite  98 jours
(type_conge != 'CONGE_MATERNITE') OR (jours_calendaires >= 98)

# Conge paternite exactement 3 jours
(type_conge != 'CONGE_PATERNITE') OR (jours_calendaires = 3)

# Solde suffisant
jours_ouvrables <= solde_conge_avant
```

---

### 6. Table : `pointage`


#### Calculs Automatiques :
- Heures théoriques vs réelles
- Retards en minutes
- Heures supplémentaires (25%, 50%, 100%)
- Validation des pointages

#### Majorations Légales :
- **25%** : Heures entre 44h et 48h/semaine (les heures qui depasse 44h legal, jusqua 48 heures)
- **50%** : Heures >48h et jours de repos
- **100%** : Jours fériés ou pendant les heures de nuit (entre 21h et 6h du matin)

---

### 7. Table : `configuration_legale`


#### Paramètres Configurables :
- SMIG/SMAG par secteur (industriel, commercial, agricole)
- Taux CNSS, AMO, CIMR
- Barème IR (JSONB pour flexibilité)
- Plafonds de cotisation
- Durées de congés légales
- Délais administratifs

---

## ⚖️ Conformité Légale Détaillée

### Code du Travail Marocain

| Article | Implémentation | Table |
|---------|----------------|-------|
| Art. 14 : Période d'essai | Max 90/180 jours | contrat_travail |
| Art. 16 : Types de contrats | CDI, CDD, mission, etc. | contrat_travail |
| Art. 62 : Préavis | 8/30/60 jours selon ancienneté | contrat_travail |
| Art. 143 : Âge minimum | 18 ans | employe |
| Art. 184 : Temps de travail | Max 44h/semaine | contrat_travail |
| Art. 234 : Congés payés | 1.5 jours/mois | contrat_travail, conge |
| Art. 245 : Congé maternité | 14 semaines | conge |

### CNSS (Caisse Nationale de Sécurité Sociale)
- **Plafond d'assiette** : 6,000 MAD (valeur pratique)
- **Taux employé** : 4.26%
- **Taux employeur** : 8.74%
- **Allocation familiale** : 150 MAD/enfant
- **Déclaration mensuelle** : Avant le 10 du mois suivant

### AMO (Assurance Maladie Obligatoire)
- **Taux employé** : 2.26%
- **Taux employeur** : 3.39%
- **Assiette** : Salaire brut

### IR (Impôt sur le Revenu)
Barème progressif automatiquement appliqué au revenu net imposable.

---

## Fonctionnalités Avancées

### 1. Colonnes Générées (Computed Columns)

```sql
-- Salaire horaire calculé
salaire_horaire DECIMAL(8,2) GENERATED ALWAYS AS (
    ROUND((salaire_base_mensuel * 12) / (52 * heures_hebdomadaires), 2)
) STORED

-- Heures réelles de travail
heures_reelles DECIMAL(4,2) GENERATED ALWAYS AS (
    CASE WHEN heure_arrivee IS NOT NULL AND heure_depart IS NOT NULL 
    THEN EXTRACT(EPOCH FROM (heure_depart - heure_arrivee)) / 3600
    ELSE 0 END
) STORED
```

### 2. Validations Complexes

```sql
# Validation cohérence nationalité/pays
CONSTRAINT chk_nationalite_consistance CHECK (
    (pays = 'Maroc' AND nationalite = 'Marocaine') OR
    (pays != 'Maroc' AND nationalite != 'Marocaine')
)

# Validation SMIG/SMAG
CONSTRAINT chk_smic CHECK (
    salaire_base_mensuel >= CASE
        WHEN type_employe = 'OUVRIER' THEN 3000 -- SMAG
        WHEN type_employe = 'EMPLOYE' THEN 3500 -- SMIG
        ELSE 0
    END
)
```

### 3. Indexation Intelligente

```sql
-- Index partiel pour les employés actifs
CREATE INDEX idx_employe_statut ON employe(statut_emploi) 
WHERE statut_emploi = 'ACTIF';

-- Index pour les documents expirés
CREATE INDEX idx_document_expiration ON document_employe(date_expiration) 
WHERE date_expiration IS NOT NULL AND est_valide = TRUE;
```

### 4. Vues pour Rapports Légaux
- **registre_personnel** : Registre obligatoire (Code du Travail)
- **etat_annuel_personnel** : Déclarations fiscales annuelles

---

##  Workflows Métier

### Embauche
1. Création fiche employé avec validation légale
2. Signature contrat (bilingue français/arabe)
3. Vérification documents obligatoires
4. Déclaration CNSS (Form D1)
5. Première paie pro-rata

### Gestion de Paie
1. Saisie heures et absences
2. Calcul automatique CNSS/AMO/IGR
3. Validation hiérarchique
4. Paiement avant échéance légale
5. Déclaration CNSS mensuelle

### Départ
1. Notification avec respect préavis
2. Calcul indemnités légales
3. Sortie CNSS
4. Certificat de travail
5. Archivage dossier (10 ans)

---

##  Contrôles Automatiques

### Batchs Mensuels

```sql
-- Vérification dossiers complets
SELECT * FROM employe 
WHERE statut_emploi = 'ACTIF' 
AND dossier_complet = FALSE;

-- Vérification déclarations CNSS
SELECT * FROM declaration_cnss
WHERE date_limite < CURRENT_DATE + INTERVAL '7 days'
AND statut != 'TRANSMISE';
```

### Alertes
- **J-30** : Fin période d'essai
- **J-7** : Échéance déclaration CNSS
- **J-30** : Documents à expirer
- **31/12** : Bilan social annuel

---

##  Sécurité et Audit

### Masquage des Données Sensibles

```sql
-- CIN masqué : XX123XXXXX78
CONCAT(SUBSTR(cin,1,2), 'XXXXX', SUBSTR(cin, -2))

-- RIB masqué : 1234 XXXX XXXX 5678
CONCAT(SUBSTR(rib,1,4), ' XXXX XXXX ', SUBSTR(rib, -4))
```

### Audit de Conformité
- Suivi des anomalies (critiques, majeures, mineures)
- Taux de conformité calculé automatiquement
- Plans d'action correctifs
- Historique des audits

---

##  Indicateurs de Performance (KPI)

### Légaux
-  100% dossiers complets
-  100% déclarations CNSS à temps
-  100% contrats écrits
-  100% visites médicales à jour

### RH
-  Taux turnover ≤ 10% (Le pourcentage d'employés qui quittent l'entreprise (démission, licenciement, non-renouvellement) sur une période donnée (généralement un an).)
-  Temps recrutement ≤ 45 jours (le delai entre le moment ou le besoin de recrutement est validé et le moment ou le candidat accepte l'offre)
-  Taux absentéisme ≤ 3%
-  Satisfaction employés ≥ 75%

---

## Maintenance et Mises à Jour

### Mises à Jour Légales
- Mettre à jour `configuration_legale` annuellement
- Ajuster SMIG/SMAG selon arrêtés ministériels
- Mettre à jour les taux CNSS/AMO
- Ajuster barème IR selon loi de finances

### Scripts de Migration

```sql
-- Mise à jour SMIG 2025
UPDATE configuration_legale 
SET smig_industriel = 3630, 
    smig_commercial = 3670,
    date_maj_smig = '2025-01-01'
WHERE annee_applicable = 2025;
```

---

## Points d'Attention

### Spécificités Marocaines
- **CIN** : 12 chiffres pour les Marocains
- **RIB** : Format marocain obligatoire
- **Contrats** : Bilingue français/arabe recommandé
- **Visite médicale** : Obligatoire pré-embauche
- **Registre du personnel** : Obligatoire et à jour

### Performances
- Index optimisés pour les requêtes fréquentes
- Partitionnement possible par année pour `fiche_paie`
- Archivage automatique des données historiques

---

## Références Légales

### Textes Officiels
- **Code du Travail** : Dahir n° 1-03-194 (loi n°65-99)
- **CNSS** : Textes réglementaires des cotisations
- **AMO** : Lois sur l'assurance maladie obligatoire
- **IR** : Loi de finances annuelle

### Conventions Collectives
- Vérifier les conventions sectorielles applicables
- Adapter les paramètres selon l'entreprise

---

##  Support et Maintenance

### Problèmes Courants
- **Documents expirés** : Alertes 30 jours avant expiration
- **Déclarations en retard** : Workflow d'urgence
- **Anomalies paie** : Recalcul automatique avec traçabilité
- **Conflits légaux** : Journalisation complète des décisions

### Contact
-  Expert-comptable marocain obligatoire
-  Avocat spécialisé droit du travail
-  Conseiller CNSS pour interprétations

---

**Document généré le** : 2025  
**Version** : 2.0  
**Conformité** : Code du Travail Marocain, CNSS, AMO, IGR
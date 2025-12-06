

---

## Table des Matières

- [Cadre Légal Marocain Applicable](#cadre-légal-marocain-applicable)
  - Code du Travail
  - CNSS
  - AMO
  - IGR
  - CIMR / Retraite Complémentaire
- [Règles de Validation des Données](#règles-de-validation-des-données)
  - Validation employé
  - Validation contrat
  - Validation paie
- [Règles de Conformité Administrative](#règles-de-conformité-administrative)
- [Règles de Gestion RH](#règles-de-gestion-rh)
  - Recrutement
  - Carrière et Promotion
  - Absences et Congés
- [Règles Financières](#règles-financières)
  - Salaire et Primes
  - Avantages sociaux obligatoires
- [Règles de Sécurité et Confidentialité](#règles-de-sécurité-et-confidentialité)
- [Contrôles Automatiques](#contrôles-automatiques)
- [Rapports Obligatoires (CNSS & Inspection du Travail)](#rapports-obligatoires-cnss--inspection-du-travail)
- [Workflows Approuvés](#workflows-approuvés)
- [Indicateurs de Conformité (KPI)](#indicateurs-de-conformité-kpi)
- [Sanctions pour Non-Conformité](#sanctions-pour-non-conformité)
- [Mises à jour et Notes de Vérification](#mises-à-jour-et-notes-de-vérification)

---

## Cadre Légal Marocain Applicable

- **Code du Travail** : Dahir n° 1-03-194 (loi n°65-99) — base légale principale pour les relations de travail.
- **CNSS** : obligations de cotisations, déclarations mensuelles, plafonds d'assiette, allocations familiales.
- **AMO** : assurance maladie obligatoire et modalités de répartition des cotisations.
- **IGR** : impôt général sur le revenu — barème progressif appliqué aux salariés.
- **CIMR / Retraite complémentaire** : selon convention collective ou contrat collectif d'entreprise.

### Articles & points de référence (exemples)
- Contrat écrit / CDD : article relatif à la forme des contrats.
- Période d'essai : plafonds (ex. 3 mois ; renouvellement selon accord).
- Durée légale du travail : 44 h/semaine (cadres / employés) — attention aux dispositions particulières.
- Congés payés : 1.5 jours ouvrables par mois travaillé.
- Registre du personnel obligatoire.

> **Remarque** : Voir la législation et les décrets d'application pour le libellé exact et les exceptions sectorielles.

---

## 1) Code du Travail (extraits utiles)

- **Article — Contrats** : Contrat écrit recommandé (CDD réservé aux cas temporaires).
- **Article — Période d'essai** : Durée encadrée; renouvellement une seule fois selon statut.
- **Article — Durée légale du travail** : 44h/semaine (vérifier pour ouvriers ou métiers spécifiques).
- **Article — Congés** : 1.5 jours ouvrables/mois.
- **Article — Préavis** : préavis minimum selon ancienneté.
- **Registre du personnel** : obligation de tenue et conservation.

---

## 2) CNSS (règles pratiques)

- Cotisations employeur / employé : appliquer les taux en vigueur et tenir compte du plafond d'assiette.
- **Plafond d'assiette (exemple vérifié lors de la revue)** : 6,000 MAD (valeur utilisée dans de nombreuses fiches pratiques et sur le site CNSS pour le calcul de la retraite et certaines assiettes).
- Déclaration mensuelle : avant l'échéance fixée (généralement le 10 du mois suivant la paie).

---

## 3) AMO (Assurance Maladie Obligatoire)

- Assiette : salaire brut + primes (selon textes applicables).
- Taux de cotisation : appliquer le taux officiel (répartition employeur / employé selon réglementation en vigueur).

---

## 4) IGR (Impôt Général sur le Revenu)

- Barème progressif appliqué au revenu net imposable. Le barème utilisé par la paie doit être celui en vigueur à la date de traitement fiscal.

---

## Règles de Validation des Données

> Ces règles sont destinées à être implémentées dans le système RH (contrôles côté API + UI + batchs de vérification).

### A. Validation employé

```sql
-- Règle 1 : CIN obligatoire pour Marocains
IF (pays = 'Maroc') THEN cin IS NOT NULL

-- Règle 2 : Passeport obligatoire pour étrangers
IF (pays != 'Maroc') THEN numero_passeport IS NOT NULL

-- Règle 3 : Age minimum 18 ans
date_naissance <= CURRENT_DATE - INTERVAL '18 years'

-- Règle 4 : Sexe valide
sexe IN ('M', 'F', 'H')

-- Règle 5 : Email professionnel format
email_professionnel ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
```

### B. Validation contrat

```sql
-- Règle 6 : Période d'essai conforme (<= 180 jours)
IF periode_essai_jours <= 180

-- Règle 7 : Préavis minimum selon ancienneté (exemple)
CASE
    WHEN anciennete_years < 1 THEN preavis_jours >= 8
    WHEN anciennete_years >= 1 AND anciennete_years < 5 THEN preavis_jours >= 30
    ELSE preavis_jours >= 60
END

-- Règle 8 : Heures hebdomadaires légales
heures_par_semaine <= 44
```

### C. Validation paie

```sql
-- Règle 9 : CNSS plafonnée (exemple pratique)
base_cnss = LEAST(salaire_base, 6000)

-- Règle 10 : Cotisation AMO (exemple)
cotisation_amo = (salaire_brut + primes) * 0.0226  -- adapter selon taux officiel

-- Règle 11 : Allocation familiale
allocation_familiale = CASE WHEN nb_personnes_charge > 0 THEN 150 * nb_personnes_charge ELSE 0 END

-- Règle 12 : Heures supplémentaires majorées
-- 25% : Heures 44-48
-- 50% : Heures >48 et jours de repos
-- 100% : Jours fériés
```

---

## Règles de Conformité Administrative

### Documents obligatoires par employé
- Copie CIN (ou passeport pour étrangers).
- RIB marocain (pour virement bancaire).
- Attestation CNSS (si ancien emploi) ou justificatifs demandés.
- Diplômes (certifiés pour postes réglementés).
- Visite médicale (pré-embauche si applicable).
- Contrat signé (version française et arabe si l'entreprise le requiert).
- Fiche de paie (conservée 5 ans ou plus selon réglementation sectorielle).

### Échéances légales (exemples pratiques)
- **Paiement des salaires** : selon politique interne mais respecter périodicité mensuelle.
- **Déclaration CNSS** : mensuelle (généralement avant le 10 du mois suivant).
- **Déclarations fiscales** : respecter dates de la DGI (selon formulaires applicables).
- **État annuel du personnel** : fin février / date légale selon textes.

---

## Règles de Gestion RH

### Recrutement

```sql
-- Règle 13 : Ratio nationalité (exemple d'objectif)
-- Objectif : >= 80% d'employés marocains (sauf exceptions pour cadres)

-- Règle 14 : Parité recommandée
-- Objectif : 30% minimum de femmes en management

-- Règle 15 : Handicap
-- Entreprise > 50 salariés : objectif d'inclusion (conformité aux textes sociaux)
```

### Carrière et Promotion

```sql
-- Règle 16 : Évaluation annuelle
-- Date limite : 31 décembre de chaque année

-- Règle 17 : Ancienneté pour promotion
-- Minimum 1 an dans le poste avant promotion interne

-- Règle 18 : Formation continue
-- Objectif : 1% de la masse salariale ou 2 jours/an pour cadres (exemple)
```

### Absences et Congés

```sql
-- Règle 19 : Congés payés
-- Droit : 1.5 jours ouvrables/mois travaillé (18 jours/an)

-- Règle 20 : Congé maladie (exemple pratique)
-- Justificatif médical obligatoire > 4 jours

-- Règle 21 : Congé maternité
-- Exemple : 14 semaines (98 jours) — prestations CNSS à appliquer

-- Règle 22 : Congé paternité
-- Exemple : 3 jours payés
```

---

## Règles Financières

### Salaire et Primes

- **SMIG / SMAG** : appliquer le SMIG/SMAG en vigueur selon la date de paie (voir mises à jour ci‑dessous).
- **Prime d'ancienneté** : politique interne à formaliser (ex. 5% après 2 ans, etc.).
- **Indemnité de licenciement** : appliquer la loi et les conventions collectives (calculer en heures/jours selon articles applicables).

### Avantages sociaux obligatoires
- Allocation familiale (selon barème CNSS et conditions d'éligibilité).
- Indemnités transport/logement : selon politique interne et conventions métiers.
- Prime de fin d'année : si prévue par contrat ou usage — vérifier engagement local.

---

## Règles de Sécurité et Confidentialité

### Données sensibles

```sql
-- Règle 26 : Masquage des identifiants sensibles
cin_masked = CONCAT(SUBSTR(cin,1,2), 'XXXX', SUBSTR(cin, -2))
iban_masked = CONCAT(SUBSTR(iban,1,4), ' XXXX XXXX XXXX ', SUBSTR(iban, -2))

-- Règle 27 : Durée conservation
-- Dossier employé : 5 ans après départ (exemple)
-- Fiches de paie : 10 ans (exemple)
```

### Accès aux données
- **RH** : accès complet (sauf restriction sur données très sensibles selon politique).
- **Manager** : accès aux données de son équipe seulement.
- **Employé** : accès à ses propres données uniquement.
- **Comptabilité** : accès aux données financières pertinentes.
- **Direction** : accès aux statistiques agrégées.

---

## Contrôles Automatiques

### Vérifications mensuelles (batchs)

```sql
-- Contrôle 1 : Complétude dossier
-- Tous les employés actifs doivent avoir : contrat_signe = true AND verification_antecedents = true

-- Contrôle 2 : Conformité CNSS
total_cotisations = SUM(cotisation_cnss_employe + cotisation_cnss_employeur)
-- Doit correspondre à base_cnss * taux_cnss_total

-- Contrôle 3 : Heures supplémentaires légales
SUM(heures_supplementaires_mois) <= 20  -- seuil interne (exemple)
```

### Alertes légales (exemples)
- **J-7** : Échéance déclaration CNSS.
- **J-30** : Fin période d'essai.
- **J-90** : Renouvellement contrats CDD.
- **31/12** : Bilan social annuel à préparer.

---

## Rapports Obligatoires (CNSS & Inspection du Travail)

### Formulaires légaux (exemples)
- **Formulaire D1** : Déclaration d'embauche (avant démarrage).
- **Formulaire D2** : Déclaration mensuelle CNSS.
- **Formulaire 9381** : Déclaration fiscale annuelle (exemple).
- **Formulaire U1** : Déclaration accidents du travail.
- **État 9432** : Déclaration des charges sociales (exemple).

### Périodicité
- **Mensuel** : D2 (CNSS), paie.
- **Trimestriel** : certaines déclarations/TVA salariale (selon cas).
- **Annuel** : 9381, 9383, bilan social.
- **Événementiel** : D1 (embauche), U1 (accident), déclaration départ.

---

## Workflows Approuvés

### Processus d'embauche (workflow)
1. Offre validée → Contrat préparé (français / arabe)
2. Signature contrat + annexes
3. Constitution dossier administratif complet
4. Visite médicale obligatoire (si applicable)
5. Déclaration CNSS (Form D1)
6. Intégration dans le SIRH
7. Première paie (pro-rata si nécessaire)

### Processus de départ (workflow)
1. Notification écrite (respect préavis)
2. Calcul indemnités (solde congés + indemnités légales)
3. Sortie CNSS (attestation de radiation)
4. Certificat de travail (délai légal)
5. Dernière paie + attestation (le cas échéant)
6. Archivage du dossier (ex : 5 ans)

---

## Indicateurs de Conformité (KPI)

### Légaux
- % Dossiers complets : objectif = 100%
- % Déclarations CNSS à temps : objectif = 100%
- % Employés avec contrat écrit : objectif = 100%
- % Visites médicales à jour : objectif = 100%

### RH
- Taux de turnover : cible ≤ 10%
- Temps moyen de recrutement : cible ≤ 45 jours
- Taux d'absentéisme : cible ≤ 3%
- Satisfaction employés : cible ≥ 75%

---

## Sanctions pour Non-Conformité (exemples)

- **CNSS** : pénalités pour retard / omission de déclaration (pourcentage des cotisations + intérêts).
- **Inspection du Travail** : amendes pour absence de registre, non-respect SMIG, travail non déclaré.
- **Fiscales** : pénalités pour retard / omission (pourcentage + intérêts).

---

## Mises à jour et Notes de Vérification

**Mises à jour appliquées lors de la génération de ce fichier :**

- **SMIG / SMAG (valeur indicative vérifiée)** : application des revalorisations décidées au 1er janvier 2025 — adapter la paie selon la date exacte de versement et les arrêtés ministériels.
- **Plafond CNSS** : valeur pratique utilisée : **6,000 MAD** (vérifier sur le site CNSS en cas d'évolution réglementaire).
- **Taux AMO / IGR / autres** : utiliser les taux officiels publiés par la CNSS et la DGI au moment du traitement.

> **Note finale** : ce document est une base juridique et opérationnelle. Avant toute application définitive, veillez à :
> 1. consulter le texte officiel (Dahir / décrets / arrêtés),
> 2. vérifier les conventions collectives applicables,
> 3. coordonner avec votre conseiller juridique / expert-comptable.

---



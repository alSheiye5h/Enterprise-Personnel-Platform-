-- Table employe avec validation legal

-- squence employe_seq
CREATE sequence employe_seq START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


CREATE TABLE employe (
    -- identifiant unique
    code_employe VARCHAR(20) PRIMARY KEY    GENERATED ALWAYS AS (
        CASE 
            WHEN pays = 'MAROC' THEN CONCAT('MA-EMP-', LPAD(nextval('employe_seq')::TEXT, 14, '0')) -- LPAD leftpad function to fill the gap in left with 0 for total of 14
            ELSE CONCAT('INT-EMP-', LPAD(nextval('employe_seq')::TEXT, 13, '0')) -- nextval recuper automatiquement une sequence de nomber
        END
    ),

    cin VARCHAR(20) CHECK (
        (pays = 'Maroc' and cin IS NOT NULL AND LENGTH(cin) = 12) or (pays != 'Maroc' and cin IS NULL)
    ),

    numero_passeport VARCHAR(20) CHECK (
        (pays != 'Maroc' AND numero_passeport IS NOT NULL)
    ),

    -- INFORMATIONS CNSS/AMO
    numero_immatriculation_cnss VARCHAR(20) NOT NULL,
    date_immatriculation_cnss DATE NOT NULL,
    numero_assure_amo VARCHAR(30),
    statut_cotisation_cnss VARCHAR(20) DEFAULT 'ACTIF' CHECK (statut_cotisation_cnss IN ('ACTIF', 'SUSPENDU', 'RADIE')),  -- suspendu si un cas special conge sans paie... , radie si l'employe a quitte l'entreprise

    -- INFORMATIONS PERSONNELLES
    prenom VARCHAR(50) NOT NULL,
    nom VARCHAR(50) NOT NULL,
    deuxieme_prenom VARCHAR(30),
    sexe VARCHAR(1) CHECK (sexe IN ('M', 'F'))    
    date_naissance date NOT NULL CHECK (
        date_naissance <= CURRENT_DATE - INTERVAL '18 years' -- minimum age 18 ans
    ),
    lieu_naissance VARCHAR(100),
    nationalite VARCHAR(50) NOT NULL DEFAULT 'Marocaine',
    situation_matrimoniale VARCHAR(20) NOT NULL CHECK (
        situation_matrimoniale IS IN ('MARIE', 'CELIBATAIRE', 'VEUF', 'DIVORCE')
    ),
    nombre_enfants INTEGER DEFAULT 0 CHECK (nombre_enfants >= 0),
    nb_personnes_charge INTEGER DEFAULT 0 CHECK (nb_personnes_charge >= 0),

    -- COORDONNEES
    email_personnel VARCHAR(100) CHECK (email_personnel ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    email_professionnel VARCHAR(100) NOT NULL CHECK (
        email_professionnel ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    telephone_mobile VARCHAR(20) NOT NULL,
    telephone_domicile VARCHAR(20),
    
    -- adress complete déclarations légales
    adresse_ligne1 VARCHAR(100) NOT NULL,
    adresse_ligne2 VARCHAR(100),
    ville VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    code_postal VARCHAR(20) NOT NULL,
    pays VARCHAR(50) NOT NULL DEFAULT 'Maroc',
    
    -- CONTACT D'URGENCE (obligatoire légal) 
    nom_contact_urgence VARCHAR(100) NOT NULL,
    telephone_contact_urgence VARCHAR(20) NOT NULL,
    relation_contact_urgence VARCHAR(30) NOT NULL,
    
    -- COORDONNÉES BANCAIRES (pour virement )
    rib VARCHAR(34) NOT NULL UNIQUE CHECK (LENGTH(rib) >= 24), -- RIB marocain
    nom_banque VARCHAR(50) NOT NULL,
    agence_bancaire VARCHAR(50),
    
    -- STATUT ADMINISTRATIF
    type_employe VARCHAR(20) NOT NULL CHECK (
        type_employe IN ('CADRE', 'EMPLOYE', 'OUVRIER', 'DIRIGEANT')
    ),
    categorie_professionnelle VARCHAR(50) CHECK (
        -- confirmite a la classification du Code du Travail
        categorie_professionnelle IN ('CATEGORIE 1', 'CATEGORIE 2', 'CATEGORIE 3', 'CATEGORIE 4', 'CATEGORIE 5')
    ),
    coefficient_hierarchique DECIMAL(5,2),
    
    -- DONNÉES EMPLOYEUR
    matricule_interne VARCHAR(20) UNIQUE,
    code_etablissement VARCHAR(20) NOT NULL, -- Pour entreprises multi-sites
    code_unite_organisationnelle VARCHAR(20),
    
    -- CONFORMITÉ ADMINISTRATIVE
    dossier_complet BOOLEAN NOT NULL DEFAULT FALSE,
    date_verification_dossier DATE,
    verificateur_dossier VARCHAR(20),
    
    -- Documents obligatoires (contrôlés par batch)
    photocopie_cin_valide BOOLEAN DEFAULT FALSE,
    rib_verifie BOOLEAN DEFAULT FALSE,
    attestation_cnss_valide BOOLEAN DEFAULT FALSE,
    diplomes_verifies BOOLEAN DEFAULT FALSE,
    visite_medicale_valide BOOLEAN DEFAULT FALSE,
    contrat_signe BOOLEAN DEFAULT FALSE,
    
    -- STATUT EMPLOI
    statut_emploi VARCHAR(20) NOT NULL DEFAULT 'ACTIF' CHECK (
        statut_emploi IN ('ACTIF', 'CONGE', 'SUSPENDU', 'LICENCIE', 'DEMISSIONNAIRE', 'RETRAITE')
    ),
    date_embauche DATE NOT NULL,
    date_fin_periode_essai DATE,
    date_depart DATE,
    motif_depart VARCHAR(100),
    
    -- MÉTADONNÉES
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    createur VARCHAR(50),
    modificateur VARCHAR(50),
    
    -- === CONTRAINTES MÉTIERS ===
    CONSTRAINT chk_nationalite_consistance CHECK (
        (pays = 'Maroc' AND nationalite = 'Marocaine') OR
        (pays != 'Maroc' AND nationalite != 'Marocaine')
    ),
    CONSTRAINT chk_email_different CHECK (
        email_personnel IS NULL OR email_personnel != email_professionnel
    )
);

-- trigger pour generer le code employe
CREATE OR REPLACE function generate_employe_code()
RETURN TRIGGER AS $$
BEGIN
    NEW.code_employe := CASE
        WHEN NEW.pays = 'Maroc' THEN
            CONCAT('MA-EMP-', LPAD(NEXTVAL('employe_seq')::TEXT, 14, '0'))
        ELSE 
            CONCAT('INT-EMP-', LPAD(NEXTVAL('employe_seq')::TEXT, 13, '0'))
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_generate_employe_code
BEFORE INSERT ON employe
FOR EACH ROW
EXECUTE FUNCTION generate_employe_code();


-- des index pour faciliter la recherche pour plus de performance
CREATE INDEX idx_emlploye_cin ON employe(cin) WHERE cin IS NOT NULL;
CREATE INDEX idx_employe_cnss ON employe(numero_immatriculation_cnss);
CREATE INDEX idx_employe_statut ON employe(statut_emploi) WHERE statut_emploi = 'ACTIF';
CREATE INDEX idx_employe_embauche ON employe(date_embauche);

-- Table contract_travail conforme au code du travail

CREATE TABLE contrat_travail (
    id_contrat SERIAL PRIMARY KEY,
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    
    -- type de contrat
    type_contrat VARCHAR(30) NOT NULL CHECK (
        type_contrat IN ('CDI', 'CDD', 'CONTRAT_MISSION', 'CONTRAT_INTERIMAIRE', 'STAGE')
    ),
    motif_cdd VARCHAR(100), -- Obligatoire pour CDD (remplacement, accroissement temporaire...)
    
    -- DATES CONTRACTUELLES 
    date_debut_contrat DATE NOT NULL,
    date_fin_contrat DATE CHECK (
        -- Pour CDD : durée maximale limitée
        (type_contrat != 'CDD') OR 
        (type_contrat = 'CDD' AND date_fin_contrat <= date_debut_contrat + INTERVAL '24 months') -- dcc ne depasse pas 2ans
    ),
    date_signature DATE NOT NULL,
    date_effet DATE NOT NULL,
    
    -- PERIODE D'ESSAI
    periode_essai_jours INTEGER NOT NULL CHECK (
        periode_essai_jours BETWEEN 0 AND CASE
            WHEN type_employe IN ('CADRE', 'DIRIGEANT') THEN 180
            ELSE 90
        END
    )
    periode_essai_renouvelable BOOLEAN DEFAULT FALSE,
    date_fin_periode_essai DATE,
    
    -- remuneration
    salaire_base_mensuel DECIMAL(10,2) NOT NULL CHECK (salaire_base_mensuel >= 0),
    salaire_horaire DECIMAL(8,2) GENERATED ALWAYS AS (
        ROUND((salaire_base_mensuel * 12) / (52 * heures_hebdomadaires), 2)
    ) STORED,
    devise VARCHAR(3) NOT NULL DEFAULT 'MAD',
    
    -- TEMPS DE TRAVAIL (Art. 184 Code du Travail)
    heures_hebdomadaires INTEGER NOT NULL CHECK (
        -- Règle 8 : Maximum 44 heures/semaine
        heures_hebdomadaires BETWEEN 1 AND 44
    ),
    heures_journalieres INTEGER CHECK (heures_journalieres BETWEEN 1 AND 10),
    jours_travail_semaine INTEGER CHECK (jours_travail_semaine BETWEEN 1 AND 6),
    regime_horaire VARCHAR(30) CHECK (
        regime_horaire IN ('JOUR', 'NUIT', 'ALTERNANT', 'POSTES')
    ),
    
    -- CONGÉS PAYÉS (Art. 234 Code du Travail)
    jours_conges_acquis DECIMAL(5,2) NOT NULL DEFAULT 1.5, -- 1.5 jours/mois travaillé
    jours_conges_prise DECIMAL(5,2) DEFAULT 0,
    solde_conges DECIMAL(5,2) GENERATED ALWAYS AS (jours_conges_acquis - jours_conges_prise) STORED,
    
    -- AVANTAGES SOCIAUX
    prime_anciennete BOOLEAN DEFAULT FALSE,
    taux_prime_anciennete DECIMAL(5,2) CHECK (taux_prime_anciennete BETWEEN 0 AND 100),
    assurance_sante BOOLEAN DEFAULT TRUE, -- AMO obligatoire
    retraite_complementaire BOOLEAN DEFAULT FALSE, -- CIMR ou autre
    mutuelle_entreprise BOOLEAN DEFAULT FALSE,
    tickets_restaurant BOOLEAN DEFAULT FALSE,
    valeur_ticket_restaurant DECIMAL(5,2),
    
    -- PRÉAVIS 
    preavis_depart_jours INTEGER NOT NULL CHECK (
        -- Règle 7 : Préavis minimum selon ancienneté
        preavis_depart_jours >= CASE
            WHEN (CURRENT_DATE - date_debut_contrat) < INTERVAL '1 year' THEN 8
            WHEN (CURRENT_DATE - date_debut_contrat) < INTERVAL '5 years' THEN 30
            ELSE 60
        END
    ),
    
    -- INDEMNITÉS
    indemnite_licenciement_calcul VARCHAR(50), -- Formule de calcul
    indemnite_preavis_calcul VARCHAR(50),
    
    -- DOCUMENTS
    chemin_contrat_pdf VARCHAR(255),
    chemin_annexes VARCHAR(255),
    contrat_bilingue BOOLEAN DEFAULT TRUE, -- Arabe/Français recommandé
    version_contrat INTEGER DEFAULT 1,
    
    -- STATUT
    statut_contrat VARCHAR(20) NOT NULL DEFAULT 'ACTIF' CHECK (
        statut_contrat IN ('ACTIF', 'SUSPENDU', 'RESILIE', 'ACHEVE', 'RUPTURE')
    ),
    motif_rupture VARCHAR(100),
    
    -- MÉTADONNÉES 
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    createur VARCHAR(50) REFERENCES employe(code_employe),
    modificateur VARCHAR(50),
    
    -- CONTRAINTES SPÉCIFIQUES
    CONSTRAINT chk_cdd_motif CHECK (
        (type_contrat != 'CDD') OR (motif_cdd IS NOT NULL)
    ),
    CONSTRAINT chk_cdd_duree CHECK (
        (type_contrat != 'CDD') OR 
        (date_fin_contrat IS NOT NULL AND date_fin_contrat > date_debut_contrat)
    ),
    CONSTRAINT chk_smic CHECK (
        -- Vérification SMIG/SMAG (à adapter selon les revalorisations)
        salaire_base_mensuel >= CASE
            WHEN type_employe = 'OUVRIER' THEN 3000 -- SMAG indicatif
            WHEN type_employe = 'EMPLOYE' THEN 3500 -- SMIG indicatif
            ELSE 0
        END
    )
);

-- TABLE : BULLETIN DE PAIE (Conformité CNSS, AMO, IGR)

CREATE TABLE fiche_paie (
    id_paie VARCHAR(30) PRIMARY KEY DEFAULT CONCAT('PAY-', TO_CHAR(CURRENT_DATE, 'YYYY-MM'), '-', LPAD(nextval('paie_seq')::TEXT, 6, '0')),
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    
    -- PÉRIODE DE PAIE
    mois_paie INTEGER NOT NULL CHECK (mois_paie BETWEEN 1 AND 12),
    annee_paie INTEGER NOT NULL CHECK (annee_paie >= 2020),
    periode_debut DATE NOT NULL, -- premier jour inclus dans le calcul du salaire et des cotisation, a partir de cette date le system commence a comptabiliser les jour de presence, les heurs travaillé, les abscences ...
    periode_fin DATE NOT NULL,
    date_etablissement DATE DEFAULT CURRENT_DATE,
    date_paiement DATE NOT NULL,
    
    -- ÉLÉMENTS DE RÉMUNÉRATION
    salaire_base DECIMAL(10,2) NOT NULL CHECK (salaire_base >= 0),
    heures_normales DECIMAL(6,2) DEFAULT 191, -- 44h/semaine * 52 semaines / 12 mois
    heures_supp_25 DECIMAL(6,2) DEFAULT 0, -- Heures 44-48
    heures_supp_50 DECIMAL(6,2) DEFAULT 0, -- Heures >48 et jours repos
    heures_supp_100 DECIMAL(6,2) DEFAULT 0, -- Jours fériés
    
    -- PRIMES ET ALLOCATIONS
    prime_anciennete DECIMAL(10,2) DEFAULT 0,
    prime_panier DECIMAL(10,2) DEFAULT 0,
    prime_transport DECIMAL(10,2) DEFAULT 0,
    prime_logement DECIMAL(10,2) DEFAULT 0,
    prime_presence DECIMAL(10,2) DEFAULT 0,
    prime_performance DECIMAL(10,2) DEFAULT 0,
    commission DECIMAL(10,2) DEFAULT 0,
    autres_primes DECIMAL(10,2) DEFAULT 0,

    -- ALLOCATIONS FAMILLIALES (CNSS)
    allocation_familliale DECIMAL(10, 2) DEFAULT 0 CHECK (
        allocation_familiale = CASE
            WHEN (SELECT nb_personnes_charge FROM employe e WHERE e.code_employe = fiche_paie.code_employe) > 0
            THEN (SELECT nb_personnes_charge FROM employe e WHERE e.code_employe = fiche_paie.code_employe) * 150
            ELSE 0
        END
    ),

    -- SALLAIRE BRUT
    salaire_brut DECIMAL(10, 2) GENERATED ALWAYS AS (
        salaire_base +
        (heures_supp_25 * (salaire_base/191) * 1.25) +
        (heures_supp_50 * (salaire_base/191) * 1.50) +
        (heures_supp_100 * (salaire_base/191) * 2.00) +
        prime_anciennete + prime_logement + prime_panier + prime_performance +
        prime_presence + prime_transport + commission + autres_primes +
        allocation_familiale
    ) STORED,

    -- ASSIETTE CNSS (plafonnee )
    assiette_cnss DECIMAL(10,2) GENERATED ALWAYS AS (
        -- Règle 9 : CNSS plafonnée à 6,000 MAD
        LEAST(salaire_brut, 6000)
    ) STORED,
    
    -- COTISATIONS CNSS
    taux_cnss_employe DECIMAL(5,4) DEFAULT 0.0426, -- 4.26%
    taux_cnss_employeur DECIMAL(5,4) DEFAULT 0.0874, -- 8.74%
    cotisation_cnss_employe DECIMAL(10,2) GENERATED ALWAYS AS (
        ROUND(assiette_cnss * taux_cnss_employe, 2)
    ) STORED,
    cotisation_cnss_employeur DECIMAL(10,2) GENERATED ALWAYS AS (
        ROUND(assiette_cnss * taux_cnss_employeur, 2)
    ) STORED,
    
    -- COTISATION AMO 
    assiette_amo DECIMAL(10,2) GENERATED ALWAYS AS (salaire_brut) STORED,
    taux_amo_employe DECIMAL(5,4) DEFAULT 0.0226, -- 2.26%
    taux_amo_employeur DECIMAL(5,4) DEFAULT 0.0339, -- 3.39%
    cotisation_amo_employe DECIMAL(10,2) GENERATED ALWAYS AS (
        ROUND(assiette_amo * taux_amo_employe, 2)
    ) STORED,
    cotisation_amo_employeur DECIMAL(10,2) GENERATED ALWAYS AS (
        ROUND(assiette_amo * taux_amo_employeur, 2)
    ) STORED,
    
    -- IMPOT SUR LE REVENU (IR)
    revenu_net_imposable DECIMAL(10,2) GENERATED ALWAYS AS (
        salaire_brut - cotisation_cnss_employe - cotisation_amo_employe
    ) STORED,
    
    -- Deduction forfaitaire et abattements
    deduction_forfaitaire DECIMAL(10,2) DEFAULT 0,
    abattement_20 DECIMAL(10,2) GENERATED ALWAYS AS (
        LEAST(ROUND((revenu_net_imposable - deduction_forfaitaire) * 0.20, 2), 2500.00)
    ) STORED,
    revenu_imposable DECIMAL(10,2) GENERATED ALWAYS AS (
        GREATEST(revenu_net_imposable - deduction_forfaitaire - abattement_20, 0)
    ) STORED,
    
    -- Calcul IGR selon barème progressif
    ir_calculé DECIMAL(10,2) GENERATED ALWAYS AS (
        CASE
            WHEN revenu_imposable <= 2500 THEN 0
            WHEN revenu_imposable <= 4166.67 THEN ROUND((revenu_imposable - 2500) * 0.10, 2) -- ROUND function to ensure that the value rendred is decimal with 2 apres virgule
            WHEN revenu_imposable <= 5000 THEN ROUND(166.67 + (revenu_imposable - 4166.67) * 0.20, 2)
            WHEN revenu_imposable <= 6666.66 THEN ROUND(333.33 + (revenu_imposable - 5000.00) * 0.30, 2)
            WHEN revenu_imposable <= 10000 THEN ROUND(833.33 + (revenu_imposable - 6666.67) * 0.34, 2)
            ELSE ROUND(1966.67 + (revenu_imposable - 10000.00) * 0.38, 2)
        END
    ) STORED,
    -- AUTRES RETENUES
    retenue_pret DECIMAL(10,2) DEFAULT 0,
    avance_salaire DECIMAL(10,2) DEFAULT 0,
    autres_retenues DECIMAL(10,2) DEFAULT 0,
    
    -- TOTAUX
    total_cotisations DECIMAL(10,2) GENERATED ALWAYS AS (
        cotisation_cnss_employe + cotisation_amo_employe + ir_calculé
    ) STORED,
    total_a_payer DECIMAL(10,2) GENERATED ALWAYS AS (
        salaire_brut - total_cotisations - retenue_pret - avance_salaire - autres_retenues
    ) STORED,
    net_a_payer DECIMAL(10,2) GENERATED ALWAYS AS (total_a_payer) STORED,
    
    -- INFORMATIONS DE PAIEMENT
    mode_paiement VARCHAR(20) NOT NULL CHECK (
        mode_paiement IN ('VIREMENT', 'CHEQUE', 'ESPECES')
    ),
    numero_virement VARCHAR(50),
    statut_paiement VARCHAR(20) NOT NULL DEFAULT 'A_PAYER' CHECK (
        statut_paiement IN ('A_PAYER', 'PAYE', 'ANNULE', 'RETARD')
    ),
    
    -- RÉFÉRENCES LÉGALES
    numero_bulletin_cnss VARCHAR(30),
    numero_declaration_fiscale VARCHAR(30),
    date_declaration_cnss DATE,
    date_declaration_fiscale DATE,
    
    -- VALIDATION
    valide_par VARCHAR(50) REFERENCES employe(code_employe),
    date_validation DATE,
    paiement_effectue_par VARCHAR(50),
    date_paiement_effectif DATE,
    
    -- MÉTADONNÉES
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- CONTRAINTES
    CONSTRAINT chk_periode CHECK (periode_fin > periode_debut),
    CONSTRAINT chk_date_paiement CHECK (date_paiement >= periode_fin),
    CONSTRAINT chk_heures_supp CHECK (
        heures_supp_25 + heures_supp_50 + heures_supp_100 <= 20 -- limite mensuelle
    )
);



































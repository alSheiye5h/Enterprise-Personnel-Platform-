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

    -- Règle 1 : CIN obligatoire pour Marocains
    cin VARCHAR(20) CHECK (
        (pays = 'Maroc' and cin IS NOT NULL AND LENGTH(cin) = 12) or (pays != 'Maroc' and cin IS NULL)
    ),

    numero_passeport VARCHAR(20) CHECK (
        -- Règle 2 : Passeport obligatoire pour étrangers
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
        -- Règle 3 : Âge minimum 18 ans (Code du Travail)
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
        -- Règle 5 : Format email valide
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
    
    -- type de contrat (Art. 16 Code du Travail)
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
    
    -- PERIODE D'ESSAI (Art. 14 Code du Travail)
    periode_essai_jours INTEGER NOT NULL CHECK (
        -- Règle 6 : Période d'essai conforme (max 180 jours selon statut)
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

-- TABLE : DÉCLARATIONS CNSS MENSUELLES
CREATE TABLE declaration_cnss (
    id_declaration SERIAL PRIMARY KEY,
    numero_declaration VARCHAR(30) UNIQUE DEFAULT CONCAT('DCNSS-', TO_CHAR(CURRENT_DATE, 'YYYYMM'), '-', LPAD(nextval('decl_seq')::TEXT, 4, '0')),
    
    -- PÉRIODE
    mois_declaration INTEGER NOT NULL CHECK (mois_declaration BETWEEN 1 AND 12),
    annee_declaration INTEGER NOT NULL,
    date_declaration DATE NOT NULL,
    date_limite DATE NOT NULL, -- generalement le 10 du mois suivant
    
    -- TOTAUX DECLARES
    total_salaires_bruts DECIMAL(12,2) NOT NULL,
    total_assiette_cnss DECIMAL(12,2) NOT NULL,
    total_cotisations_employe DECIMAL(12,2) NOT NULL,
    total_cotisations_employeur DECIMAL(12,2) NOT NULL,
    total_cotisations_amo_employe DECIMAL(12,2) NOT NULL,
    total_cotisations_amo_employeur DECIMAL(12,2) NOT NULL,
    total_general DECIMAL(12,2) NOT NULL,
    
    -- ÉTAT
    statut VARCHAR(20) NOT NULL DEFAULT 'BROUILLON' CHECK (
        statut IN ('BROUILLON', 'VALIDEE', 'TRANSMISE', 'ACCEPTEE', 'REJETEE')
    ),
    date_transmission DATE,
    date_acceptation DATE,
    reference_acceptation VARCHAR(50),
    
    -- DOCUMENTS
    fichier_declaration VARCHAR(255),
    fichier_quittance VARCHAR(255),
    observations TEXT,
    
    -- RESPONSABLE
    declare_par VARCHAR(50) NOT NULL,
    verifie_par VARCHAR(50),
    
    -- MÉTADONNÉES
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- TABLE : GESTION DES CONGÉS (Conformité Code du Travail)
CREATE TABLE conge (
    id_conge SERIAL PRIMARY KEY,
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    
    -- TYPE DE CONGÉ (Article 234 a 247 code du travail)
    type_conge VARCHAR(30) NOT NULL CHECK (
        type_conge IN (
            'CONGE_ANNUEL', 
            'CONGE_MALADIE', 
            'CONGE_MATERNITE', 
            'CONGE_PATERNITE',
            'CONGE_EXCEPTIONNEL',
            'CONGE_SANS_SOLDE'
        )
    ),
    
    -- PÉRIODE
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    date_demande DATE DEFAULT CURRENT_DATE,
    
    -- DURÉE
    jours_ouvrables DECIMAL(5,2) NOT NULL CHECK (jours_ouvrables > 0),
    jours_calendaires DECIMAL(5,2) GENERATED ALWAYS AS (
        date_fin - date_debut + 1
    ) STORED,
    
    -- CONGÉS SPÉCIFIQUES 
    -- Congé maternité (14 semaines)
    certificat_medical_maternite VARCHAR(100),
    date_accouchement DATE,
    
    -- Congé maladie
    certificat_medical VARCHAR(100),
    maladie_professionnelle BOOLEAN DEFAULT FALSE,
    
    -- WORKFLOW D'APPROBATION
    statut_demande VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE' CHECK (
        statut_demande IN ('EN_ATTENTE', 'APPROUVE', 'REJETE', 'ANNULE')
    ),
    approbateur VARCHAR(20) REFERENCES employe(code_employe),
    date_approbation DATE,
    motif_rejet VARCHAR(200),
    
    -- IMPACT PAIE 
    solde_conge_avant DECIMAL(5,2) NOT NULL,
    solde_conge_apres DECIMAL(5,2) GENERATED ALWAYS AS (
        solde_conge_avant - jours_ouvrables
    ) STORED,
    deduction_salaire DECIMAL(10,2) DEFAULT 0,
    pris_en_compte_paie BOOLEAN DEFAULT FALSE,
    
    -- RÈGLES LÉGALES
    conge_paye BOOLEAN GENERATED ALWAYS AS (
        CASE type_conge
            WHEN 'CONGE_MALADIE' THEN jours_calendaries > 4 -- Justificatif obligatoire > 4 jours
            ELSE TRUE
        END
    ) STORED,
    
    -- MÉTADONNÉES
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- CONTRAINTES
    CONSTRAINT chk_periode_conge CHECK (date_fin >= date_debut),
    CONSTRAINT chk_conge_maternite CHECK (
        (type_conge != 'CONGE_MATERNITE') OR 
        (jours_calendaires >= 98) -- 14 semaines
    ),
    CONSTRAINT chk_conge_paternite CHECK (
        (type_conge != 'CONGE_PATERNITE') OR 
        (jours_calendaires = 3)
    ),
    CONSTRAINT chk_solde_suffisant CHECK (jours_ouvrables <= solde_conge_avant)
);

-- TABLE : POINTAGE ET TEMPS DE TRAVAIL
CREATE TABLE pointage (
    id_pointage SERIAL PRIMARY KEY,
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    
    -- JOURNEE
    date_pointage DATE NOT NULL,
    jour_semaine VARCHAR(10) GENERATED ALWAYS AS (
        TO_CHAR(date_pointage, 'Day') -- extraire le nom complet du jour
    ) STORED,
    est_jour_ferie BOOLEAN DEFAULT FALSE,
    est_weekend BOOLEAN GENERATED ALWAYS AS (
        EXTRACT(DOW FROM date_pointage) IN (0, 6)
    ) STORED,
    
    -- HORAIRES THEORIQUES
    heure_debut_theorique TIME NOT NULL,
    heure_fin_theorique TIME NOT NULL,
    pause_debut TIME,
    pause_fin TIME,
    
    -- POINTAGES REEL
    heure_arrivee TIME,
    heure_depart TIME,
    pointage_entree_valide BOOLEAN DEFAULT FALSE,
    pointage_sortie_valide BOOLEAN DEFAULT FALSE,
    
    -- CALCUL
    heures_theoriques DECIMAL(4,2) GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (heure_fin_theorique - heure_debut_theorique -
        COALESCE(pause_fin - pause_debut, '00:00'::INTERVAL))) / 3600 -- coalesce(..) pour s assurer que si la pause est null ca va pas etre compter
    ) STORED,
    
    heures_reelles DECIMAL(4,2) GENERATED ALWAYS AS (
        CASE 
            WHEN heure_arrivee IS NOT NULL AND heure_depart IS NOT NULL 
            THEN EXTRACT(EPOCH FROM (heure_depart - heure_arrivee -
                 COALESCE(pause_fin - pause_debut, '00:00'::INTERVAL))) / 3600
            ELSE 0
        END
    ) STORED,
    
    retard_minutes INTEGER GENERATED ALWAYS AS (
        CASE 
            WHEN heure_arrivee IS NOT NULL AND heure_arrivee > heure_debut_theorique
            THEN EXTRACT(EPOCH FROM (heure_arrivee - heure_debut_theorique)) / 60
            ELSE 0
        END
    ) STORED,
    
    -- HEURES SUPPLÉMENTAIRES
    heures_supp_25 DECIMAL(4,2) DEFAULT 0,
    heures_supp_50 DECIMAL(4,2) DEFAULT 0,
    heures_supp_100 DECIMAL(4,2) DEFAULT 0,
    
    -- ABSENCES
    absence BOOLEAN DEFAULT FALSE,
    type_absence VARCHAR(30) CHECK (
        type_absence IN ('MALADIE', 'CONGE', 'AUTORISATION', 'NON_JUSTIFIEE')
    ),
    justificatif_absence VARCHAR(100),
    
    -- VALIDATION
    statut_pointage VARCHAR(20) DEFAULT 'SAISI' CHECK (
        statut_pointage IN ('SAISI', 'CORRIGE', 'VALIDE', 'REJETE')
    ),
    validateur VARCHAR(20) REFERENCES employe(code_employe),
    date_validation DATE,
    
    -- OBSERVATIONS
    observations TEXT,
    
    -- MÉTADONNÉES
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- CONTRAINTES
    CONSTRAINT chk_heure_fin CHECK (heure_fin_theorique > heure_debut_theorique),
    CONSTRAINT chk_pointage_complet CHECK (
        (absence = TRUE) OR 
        (heure_arrivee IS NOT NULL AND heure_depart IS NOT NULL)
    ),
    CONSTRAINT uk_pointage_jour UNIQUE (code_employe, date_pointage)
);

-- TABLE : CONFIGURATION FISCALE ET SOCIALE (Parametres legaux)

CREATE TABLE configuration_legale (
    id_config SERIAL PRIMARY KEY,
    
    -- IDENTIFICATION
    code_pays VARCHAR(5) NOT NULL DEFAULT 'MA',
    annee_applicable INTEGER NOT NULL,
    date_debut_validite DATE NOT NULL,
    date_fin_validite DATE,
    
    -- SMIG/SMAG
    smig_industriel DECIMAL(10,2) NOT NULL, -- Salaire minimum industriel
    smig_commercial DECIMAL(10,2) NOT NULL,
    smig_agricole DECIMAL(10,2) NOT NULL,
    date_maj_smig DATE NOT NULL,
    
    -- BARÈME IR
    bareme_ir JSONB NOT NULL CHECK (jsonb_typeof(bareme_ir) = 'array'),
    deduction_forfaitaire DECIMAL(10,2) NOT NULL,
    abattement_taux DECIMAL(5,4) NOT NULL DEFAULT 0.20,
    
    -- CNSS
    plafond_cnss DECIMAL(10,2) NOT NULL DEFAULT 6000,
    taux_cnss_employe DECIMAL(5,4) NOT NULL,
    taux_cnss_employeur DECIMAL(5,4) NOT NULL,
    taux_allocation_familiale DECIMAL(5,4), -- Par enfant
    montant_allocation_familiale DECIMAL(10,2) NOT NULL DEFAULT 150,
    
    -- AMO
    taux_amo_employe DECIMAL(5,4) NOT NULL,
    taux_amo_employeur DECIMAL(5,4) NOT NULL,
    plafond_amo DECIMAL(10,2), -- Si plafonné
    
    -- RETRAITE COMPLÉMENTAIRE (CIMR)
    taux_cimr_employe DECIMAL(5,4),
    taux_cimr_employeur DECIMAL(5,4),
    plafond_cimr DECIMAL(10,2),
    
    -- HEURES SUPPLÉMENTAIRES
    taux_hsup_25 DECIMAL(5,4) NOT NULL DEFAULT 0.25,
    taux_hsup_50 DECIMAL(5,4) NOT NULL DEFAULT 0.50,
    taux_hsup_100 DECIMAL(5,4) NOT NULL DEFAULT 1.00,
    limite_mensuelle_hsup DECIMAL(6,2) DEFAULT 20,
    
    -- CONGÉS
    taux_acquisition_conges DECIMAL(5,2) NOT NULL DEFAULT 1.5, -- Jours/mois
    duree_conge_maternite_jours INTEGER DEFAULT 98,
    duree_conge_paternite_jours INTEGER DEFAULT 3,
    
    -- FORMALITES ADMINISTRATIVES
    delai_declaration_cnss_jours INTEGER DEFAULT 10, -- Jours après fin de mois
    delai_paiement_salaire_jours INTEGER DEFAULT 15, -- Dernier jour du mois
    
    -- MÉTADONNEES
    source_officielle VARCHAR(255),
    reference_juridique VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    
    -- CONTRAINTES
    CONSTRAINT uk_config_periode UNIQUE (code_pays, annee_applicable)
);

-- TABLES DE LIENS ET RELATIONS
CREATE TABLE employe_departement (
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    code_departement VARCHAR(20) NOT NULL,
    date_affectation DATE NOT NULL DEFAULT CURRENT_DATE,
    date_fin_affectation DATE,
    pourcentage_allocation DECIMAL(5,2) NOT NULL CHECK (pourcentage_allocation BETWEEN 0 AND 100),
    manager_departement BOOLEAN DEFAULT FALSE,
    statut_affectation VARCHAR(20) DEFAULT 'ACTIVE' CHECK (
        statut_affectation IN ('ACTIVE', 'HISTORIQUE', 'FUTURE')
    ),
    PRIMARY KEY (code_employe, code_departement, date_affectation)
);

-- Table de suivi des formations
CREATE TABLE formation_employe (
    id_formation SERIAL PRIMARY KEY,
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    intitule_formation VARCHAR(200) NOT NULL,
    type_formation VARCHAR(50) NOT NULL,
    organisme_formateur VARCHAR(100),
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    duree_heures INTEGER NOT NULL,
    cout_formation DECIMAL(10,2),
    prise_en_charge_entreprise DECIMAL(5,2) DEFAULT 100,
    certification_obtenue BOOLEAN DEFAULT FALSE,
    nom_certification VARCHAR(100),
    valide_par VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des compétences
CREATE TABLE competence_employe (
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    code_competence VARCHAR(20) NOT NULL,
    nom_competence VARCHAR(100) NOT NULL,
    niveau_maitrise VARCHAR(20) CHECK (niveau_maitrise IN ('DEBUTANT', 'INTERMEDIAIRE', 'AVANCE', 'EXPERT')),
    date_acquisition DATE NOT NULL,
    date_expiration DATE,
    certifie_par VARCHAR(50),
    organisme_certificateur VARCHAR(100),
    PRIMARY KEY (code_employe, code_competence)
);

-- TABLE : SUIVI DES DOCUMENTS OBLIGATOIRES
CREATE TABLE document_employe (
    id_document SERIAL PRIMARY KEY,
    code_employe VARCHAR(20) NOT NULL REFERENCES employe(code_employe),
    type_document VARCHAR(50) NOT NULL CHECK (
        type_document IN (
            'CIN',
            'PASSEPORT',
            'RIB',
            'DIPLOME',
            'ATTESTATION_CNSS',
            'VISITE_MEDICALE',
            'CONTRAT',
            'CERTIFICAT_TRAVAIL',
            'AUTRE'
        )
    ),
    nom_document VARCHAR(100) NOT NULL,
    chemin_fichier VARCHAR(255) NOT NULL,
    date_emission DATE,
    date_expiration DATE,
    est_valide BOOLEAN DEFAULT TRUE,
    date_validation DATE,
    validateur VARCHAR(50),
    observations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Alerte automatique 30 jours avant expiration
    CONSTRAINT chk_expiration CHECK (date_expiration IS NULL OR date_expiration > CURRENT_DATE)
);

-- TABLE : AUDIT ET SUIVI DE CONFORMITÉ
CREATE TABLE audit_conformite (
    id_audit SERIAL PRIMARY KEY,
    
    -- SCOPE AUDIT
    type_audit VARCHAR(50) NOT NULL CHECK (
        type_audit IN ('PAIE', 'CNSS', 'CONTRAT', 'DOCUMENTS', 'TEMPS_TRAVAIL')
    ),
    periode_audit_debut DATE NOT NULL,
    periode_audit_fin DATE NOT NULL,
    date_audit DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- RÉSULTATS
    nombre_anomalies INTEGER DEFAULT 0,
    anomalies_critiques INTEGER DEFAULT 0,
    anomalies_majeures INTEGER DEFAULT 0,
    anomalies_mineures INTEGER DEFAULT 0,
    
    -- STATISTIQUES
    taux_conformite DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN nombre_anomalies = 0 THEN 100
            ELSE GREATEST(100 - (nombre_anomalies * 5), 0) -- calcul simplifie
        END
    ) STORED,
    
    -- RAPPORT
    observations TEXT,
    recommandations TEXT,
    plan_action TEXT,
    
    -- RESPONSABLES
    auditeur VARCHAR(50) NOT NULL,
    valide_par VARCHAR(50),
    date_validation DATE,
    
    --  METADONNEES 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- CONTRAINTES
    CONSTRAINT chk_periode_audit CHECK (periode_audit_fin > periode_audit_debut)
);

-- vue pour le registre du personnel 
CREATE OR REPLACE VIEW registre_personnel AS
SELECT 
    e.code_employe,
    e.cin,
    e.prenom || ' ' || e.nom AS nom_complet,
    e.date_naissance,
    e.lieu_naissance,
    e.nationalite,
    e.adresse_ligne1 || COALESCE(', ' || e.adresse_ligne2, '') || ', ' || e.ville AS adresse_complete,
    e.telephone_mobile,
    e.email_professionnel,
    e.date_embauche,
    ct.type_contrat,
    ct.date_debut_contrat,
    ct.salaire_base_mensuel,
    e.statut_emploi,
    e.numero_immatriculation_cnss
FROM employe e
LEFT JOIN contrat_travail ct ON e.code_employe = ct.code_employe 
    AND ct.statut_contrat = 'ACTIF'
WHERE e.statut_emploi = 'ACTIF';

-- vue pour l'etat annuel du personnel (déclaration fiscale)
CREATE OR REPLACE VIEW etat_annuel_personnel AS
SELECT 
    EXTRACT(YEAR FROM fp.periode_fin) AS annee,
    e.code_employe,
    e.cin,
    e.prenom || ' ' || e.nom AS nom_complet,
    SUM(fp.salaire_brut) AS salaire_brut_annuel,
    SUM(fp.cotisation_cnss_employe) AS cotisation_cnss_annuelle,
    SUM(fp.cotisation_amo_employe) AS cotisation_amo_annuelle,
    SUM(fp.igr_calculé) AS igr_annuel,
    COUNT(DISTINCT fp.mois_paie) AS mois_payes
FROM fiche_paie fp
JOIN employe e ON fp.code_employe = e.code_employe
WHERE e.statut_emploi = 'ACTIF'
GROUP BY EXTRACT(YEAR FROM fp.periode_fin), e.code_employe, e.cin, e.prenom, e.nom;

-- Indexes
CREATE INDEX idx_employe_nom_prenom ON employe(nom, prenom);
CREATE INDEX idx_employe_date_embauche ON employe(date_embauche);
CREATE INDEX idx_fiche_paie_periode ON fiche_paie(periode_debut, periode_fin);
CREATE INDEX idx_fiche_paie_employe ON fiche_paie(code_employe);
CREATE INDEX idx_conge_employe ON conge(code_employe, date_debut);
CREATE INDEX idx_pointage_employe_date ON pointage(code_employe, date_pointage);
CREATE INDEX idx_document_expiration ON document_employe(date_expiration) 
    WHERE date_expiration IS NOT NULL AND est_valide = TRUE;



























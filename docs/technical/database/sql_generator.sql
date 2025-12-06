-- Table employe avec validation legal

-- squence employe_seq
CREATE sequence employe_seq START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


CREATE TABLE employe {
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
};

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




































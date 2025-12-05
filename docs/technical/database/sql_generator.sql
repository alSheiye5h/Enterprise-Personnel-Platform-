-- Table employe avec validation legal

-- squence employe_seq
CREATE sequence employe_seq START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


CREATE TABLE employe {
    -- identifiant unique
    code_employe VARCHAR(20) PRIMARY KEY GENERATED ALWAYS AS (
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
}
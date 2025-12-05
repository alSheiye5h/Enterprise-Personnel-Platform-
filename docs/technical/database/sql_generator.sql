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

    prenom VARCHAR(50) NOT NULL,
    nom VARCHAR(50) NOT NULL,
    deuxieme_prenom VARCHAR(30),
    sexe VARCHAR(1) CHECK (sexe IN ('M', 'F'))    
    date_naissance date NOT NULL CHECK (
        date_naissance <= CURRENT_DATE - INTERVAL '18 years' -- minimum age 18 ans
    ),
    lieu_naissance VARCHAR(100),






}
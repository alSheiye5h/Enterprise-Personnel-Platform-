table employer {
  code_employer varchar // 20 char
  cin varchar // 15 char
  numero_passport varchar // 20 char

  // personal info
  prenom varchar // 50 char
  nom varchar // 50 char
  surnom varchar // 50
  sexe char // 1 char enum
  date_de_naissance date // tm struct from time.h
  situation_matrimonial varchar // 15 char enum
  personne_a_charge integer // dependents personnes for taxs

  // coordonnées
  email_personnel varchar // 100 char
  email_professionnel varhcar // 100 char
  telephone_mobile int 
  telephone_domicille int
  ville varchar // char 20
  region varhcar // char 20
  code_postal int

  // contact d'urgence
  nom_contact_urgence varchar // 50 cahr
  telephone_contact_urgence  int
  relation_avec_contact_urgence varchar // 15 char

  // les relations
  code_departement varchar // 20 char
  code_poste varchar // 20 cahr
  code_manager varchar // 20 char

  // status professionnel
  status_employer varchar // enum
  date_embauche date // tm from time.h
  date_fin_periode_essai date // tm from time.h
  date_demission date // tm ...

  // conformité
  contract_signe boolean 
  verification_antecedents bolean
  verifie boolean

  // regle metier
  valid boolean 

}


table departement {
  code_departement varchar // 20 char
  nom_departement varchar // 30 char
  type_departement varchar // 50 char
  code_centre_coup varchar // 30 char
  code_localisation varchar // 20 char
  code_manager varchar // 20 char
  date_creation date // tm time.h
  budget_annuel float 
  effectif_approuve int
  effectif_actuel int

  // structure hierarchique
  code_departement_parent varchar // 20 char
  niveau_hierarchique int 
}













































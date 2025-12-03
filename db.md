table employer {
  code_employer varchar // 15 char
  cin varchar // 15 char
  numero_passport varchar // 15 char

  // personal info
  prenom varchar // 50 char
  nom varchar // 50 char
  surnom varchar // 50
  sexe char // 1 char
  date_de_naissance date // tm struct from time.h
  situation_matrimonial varchar // 15 char
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
  nom_contact_durgence varchar // 50 cahr
  telephone_contact_durgence  int
  relation_avec_contact_durgence varchar // 15 char

  // les relations
  code_departement varchar // 20 char
  code_poste varchar // 20 cahr



}
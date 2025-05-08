# 🚀 Connecteur Salesforce <> Pappers 

Ce projet permet d’enrichir simplement les fiches **Compte (Account)** dans Salesforce  
en interrogeant l'API **Pappers.fr** directement via un bouton d'action rapide.

---

## 📚 Fonctionnalités

- Bouton **"Enrichir avec Pappers 🚀"** ajouté sur la fiche Compte
- Appel direct à l'API Pappers
- Mise à jour automatique des informations du Compte :
  - SIREN
  - Forme juridique
  - Code NAF
  - Activité
  - Téléphone
  - Adresse
- Notification Toast de succès ou d'échec dans le Flow 

---

## 🏗️ Architecture du Projet

| Composant | Description |
|:----------|:------------|
| `PappersEnrichmentService.cls` | Classe Apex pour l’appel API Pappers et mise à jour de l’Account (IA-Gen) |
| `PappersEnrichmentServiceTest.cls` | Classe de test unitaire pour valider l'intégration (IA-Gen) |
| `PappersAPIAccountEnrichment.flow-meta.xml` | Flow Salesforce (Screen Flow) |
| `QuickAction: Enrichir_avec_Pappers` | Bouton pour lancer le Flow |
| `Custom Fields sur Account` | `SIREN__c`, `FormeJuridique__c`, `Code_NAF__c`, `Activite__c` |

---

## 🚀 Déploiement

[![Deploy to Salesforce](https://githubsfdeploy.herokuapp.com/resources/img/deploy.png)](https://githubsfdeploy.herokuapp.com/?owner=rmalier&repo=SalesforcePappersConnecteur&ref=main&path=force-app/main/default)
---

## 🧩 Post-déploiement

Après installation :
1. **Ajoutez le bouton rapide** "Enrichir avec Pappers 🚀" sur la page de détails `Compte (Account)`.
2. **Activez le Flow** si besoin (`PappersAPIAccountEnrichment`).
3. **Configurez votre clé API Pappers** ➔ très important :

---

## 🔐 Mise à jour obligatoire de la clé API

Par défaut, la classe `PappersEnrichmentService.cls` contient un champ placeholder pour la clé API.

**Vous devez modifier ce fichier Apex** :
```apex
// Remplacez 'VOTRE_CLE_API_ICI' par votre vraie clé API Pappers Pro
String apiToken = 'VOTRE_CLE_API_ICI';
```

➡️ Sans cette modification, l’appel API ne fonctionnera pas.


### 📦 Structure du projet
```
force-app/
└── main/
    └── default/
        ├── classes/
        │   ├── PappersEnrichmentService.cls
        │   └── PappersEnrichmentServiceTest.cls
        ├── flows/
        │   └── PappersAPIAccountEnrichment.flow-meta.xml
        ├── objects/
        │   └── Account/
        │       └── fields/
        │           ├── Activite__c.field-meta.xml
        │           ├── Code_NAF__c.field-meta.xml
        │           ├── FormeJuridique__c.field-meta.xml
        │           └── SIREN__c.field-meta.xml
        └── quickActions/
            └── Account.Enrichir_avec_Pappers.quickAction-meta.xml
```

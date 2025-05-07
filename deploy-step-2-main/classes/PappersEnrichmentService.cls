public with sharing class PappersEnrichmentService {

    private static final String PAPPERS_ENDPOINT = 'https://api.pappers.fr/v2/recherche';
    private static final String API_TOKEN = 'CLE_API'; // Remplacer par ta clé API

    @InvocableMethod(label='Enrichir un compte avec Pappers et retour infos')
    public static List<PappersInfo> enrichAccounts(List<Id> accountIds) {
        List<PappersInfo> output = new List<PappersInfo>();

        if (accountIds == null || accountIds.isEmpty()) {
            throw new AuraHandledException('Aucun compte fourni.');
        }
        Id accountId = accountIds[0];

        Account acc = [SELECT Id, Name, BillingPostalCode FROM Account WHERE Id = :accountId LIMIT 1];
        if (acc == null || String.isBlank(acc.Name)) {
            throw new AuraHandledException('Le compte est introuvable ou sans nom.');
        }

        // Construction dynamique de l'URL avec ou sans code postal
        String endpointUrl = PAPPERS_ENDPOINT + '?api_token=' + API_TOKEN + '&nom_entreprise=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8');

        if (!String.isBlank(acc.BillingPostalCode)) {
            endpointUrl += '&code_postal=' + EncodingUtil.urlEncode(acc.BillingPostalCode, 'UTF-8');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> results = (List<Object>) payload.get('resultats');

            if (!results.isEmpty()) {
                Map<String, Object> firstResult = (Map<String, Object>) results[0];
                Map<String, Object> siege = (Map<String, Object>) firstResult.get('siege');

                if (firstResult.get('siren') != null) {
                    acc.SIREN__c = Decimal.valueOf(String.valueOf(firstResult.get('siren')));
                }
                acc.FormeJuridique__c = (String) firstResult.get('forme_juridique');
                acc.Code_NAF__c = (String) firstResult.get('code_naf');

                String libelleCodeNaf = (String) firstResult.get('libelle_code_naf');
                String domaineActivite = (String) firstResult.get('domaine_activite');

                if (libelleCodeNaf != null && domaineActivite != null) {
                    acc.Activite__c = libelleCodeNaf + ' - ' + domaineActivite;
                } else if (libelleCodeNaf != null) {
                    acc.Activite__c = libelleCodeNaf;
                } else if (domaineActivite != null) {
                    acc.Activite__c = domaineActivite;
                } else {
                    acc.Activite__c = null;
                }

                acc.Phone = siege != null ? (String) siege.get('telephone') : null;
                acc.BillingStreet = siege != null ? (String) siege.get('adresse_ligne_1') : null;

                if (siege != null && siege.get('code_postal') != null) {
                    Object cp = siege.get('code_postal');
                    if (cp instanceof Decimal) {
                        acc.BillingPostalCode = String.valueOf((Decimal) cp);
                    } else if (cp instanceof String) {
                        acc.BillingPostalCode = (String) cp;
                    } else {
                        acc.BillingPostalCode = null;
                    }
                } else {
                    acc.BillingPostalCode = null;
                }

                acc.BillingCity = siege != null ? (String) siege.get('ville') : null;
                acc.BillingCountry = 'France';

                update acc;

                // Création de l'objet à retourner au Flow
                PappersInfo info = new PappersInfo();
                info.siren = String.valueOf(firstResult.get('siren'));
                info.formeJuridique = (String) firstResult.get('forme_juridique');
                info.telephone = siege != null ? (String) siege.get('telephone') : null;
                info.adresse = siege != null ? (String) siege.get('adresse_ligne_1') : null;
                info.codePostal = siege != null ? String.valueOf(siege.get('code_postal')) : null;
                info.ville = siege != null ? (String) siege.get('ville') : null;
                info.activite = acc.Activite__c;
                info.codeNAF = (String) firstResult.get('code_naf');

                output.add(info);
            } else {
                throw new AuraHandledException('Aucun résultat trouvé pour ce compte dans Pappers.');
            }
        } else {
            throw new AuraHandledException('Erreur lors de l\'appel à l\'API Pappers : ' + res.getStatus());
        }
        return output;
    }

    // Classe pour renvoyer les infos au Flow
    public class PappersInfo {
        @InvocableVariable public String siren;
        @InvocableVariable public String formeJuridique;
        @InvocableVariable public String telephone;
        @InvocableVariable public String adresse;
        @InvocableVariable public String codePostal;
        @InvocableVariable public String ville;
        @InvocableVariable public String activite;
        @InvocableVariable public String codeNAF;
    }
}
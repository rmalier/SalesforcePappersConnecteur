@isTest
public class PappersEnrichmentServiceTest {

    @isTest
    static void testEnrichAccount() {

        // Création d'un compte factice pour le test
        Account testAccount = new Account();
        testAccount.Name = 'Test Entreprise';
        insert testAccount;

        // Simulation de la réponse HTTP de l'API Pappers
        Test.setMock(HttpCalloutMock.class, new PappersApiMock());

        // Appel de la méthode d'enrichissement
        Test.startTest();
List<Id> accountIds = new List<Id>{ testAccount.Id };
PappersEnrichmentService.enrichAccounts(accountIds);
        Test.stopTest();

        // Vérification du compte enrichi
        Account enrichedAccount = [SELECT Id, SIREN__c, FormeJuridique__c, Phone, BillingStreet, BillingPostalCode, BillingCity, BillingCountry FROM Account WHERE Id = :testAccount.Id LIMIT 1];

        // Assertions
        System.assertEquals('123456789', String.valueOf(enrichedAccount.SIREN__c));
        System.assertEquals('SAS, société par actions simplifiée', enrichedAccount.FormeJuridique__c);
        System.assertEquals('01 23 45 67 89', enrichedAccount.Phone);
        System.assertEquals('123 Rue Exemple', enrichedAccount.BillingStreet);
        System.assertEquals('75001', enrichedAccount.BillingPostalCode);
        System.assertEquals('Paris', enrichedAccount.BillingCity);
        System.assertEquals('France', enrichedAccount.BillingCountry);
    }

    // Classe Mock intégrée pour simuler la réponse de l'API Pappers
    private class PappersApiMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{' +
                '"resultats": [' +
                '  {' +
                '    "siren": "123456789",' +
                '    "forme_juridique": "SAS, société par actions simplifiée",' +
                '    "siege": {' +
                '      "telephone": "01 23 45 67 89",' +
                '      "adresse_ligne_1": "123 Rue Exemple",' +
                '      "code_postal": "75001",' +
                '      "ville": "Paris"' +
                '    }' +
                '  }' +
                ']' +
                '}');
            return res;
        }
    }
}
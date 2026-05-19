/**
 * @description Tests unitaires pour LivraisonController.
 *              Couvre les 4 méthodes @AuraEnabled + cas limites.
 *              Objectif : ≥ 85% de couverture.
 *              Commandes en Draft — trigger ne valide ni produits ni transporteur.
 */
@IsTest
private class LivraisonControllerTest {

    @TestSetup
    static void setup() {

        Id pricebookId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'Produit Test', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id   = prod.Id,
            UnitPrice    = 100,
            IsActive     = true
        );
        insert pbe;

        Account particulier = new Account(
            Name          = 'Client Particulier Test',
            TypeClient__c = 'Particulier'
        );
        insert particulier;

        Account professionnel = new Account(
            Name          = 'Client Pro Test',
            TypeClient__c = 'Professionnel'
        );
        insert professionnel;

        // Transporteur A — France + Particulier (moins cher)
        Transporteur__c t1 = new Transporteur__c(
            Name                  = 'TransporteurA',
            Pays__c               = 'France',
            TypeClient__c         = 'Particulier',
            Prix__c               = 10,
            Delai_de_livraison__c = 3
        );
        insert t1;

        // Transporteur B — France + Particulier (plus rapide)
        Transporteur__c t2 = new Transporteur__c(
            Name                  = 'TransporteurB',
            Pays__c               = 'France',
            TypeClient__c         = 'Particulier',
            Prix__c               = 20,
            Delai_de_livraison__c = 1
        );
        insert t2;

        // Prix de livraison — France uniquement
        insert new Prix_de_livraison__c(Name='10', Transporteur__c=t1.Id, Pays__c='France', Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='20', Transporteur__c=t2.Id, Pays__c='France', Delai_de_livraison__c=1);

        // Commande particulier France en Draft
        Order cmd = new Order(
            AccountId       = particulier.Id,
            Pays__c         = 'France',
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pricebook2Id    = pricebookId
        );
        insert cmd;
    }

    // ─────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────

    private static Id getOrderId() {
        return [SELECT Id FROM Order WHERE Account.TypeClient__c = 'Particulier'
                AND Pays__c = 'France' LIMIT 1].Id;
    }

    private static Id getTransporteurId(String nom) {
        return [SELECT Id FROM Transporteur__c WHERE Name = :nom LIMIT 1].Id;
    }

    private static Order createOrder(Id accountId, String pays) {
        Order cmd = new Order(
            AccountId     = accountId,
            Pays__c       = pays,
            Status        = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id  = Test.getStandardPricebookId()
        );
        insert cmd;
        return cmd;
    }

    // ─────────────────────────────────────────────────────────────
    // getMoinsCher
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testGetMoinsCher_retourneLeMoinsCher() {
        Id orderId = getOrderId();
        Test.startTest();
        LivraisonController.TransporteurOption result = LivraisonController.getMoinsCher(orderId);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Doit retourner un transporteur');
        System.assertEquals('TransporteurA', result.nom, 'TransporteurA doit être le moins cher');
        System.assertEquals(10, result.prix, 'Prix attendu : 10');
    }

    @IsTest
    static void testGetMoinsCher_aucunTransporteur_retourneNull() {
        Account particulier = [SELECT Id FROM Account WHERE TypeClient__c = 'Particulier' LIMIT 1];
        // Belgique — aucun transporteur Particulier disponible
        Order cmd = createOrder(particulier.Id, 'Belgique');

        Test.startTest();
        LivraisonController.TransporteurOption result = LivraisonController.getMoinsCher(cmd.Id);
        Test.stopTest();

        System.assertEquals(null, result, 'Doit retourner null — aucun transporteur Particulier en Belgique');
    }

    // ─────────────────────────────────────────────────────────────
    // getPlusRapide
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testGetPlusRapide_retourneLePlusRapide() {
        Id orderId = getOrderId();
        Test.startTest();
        LivraisonController.TransporteurOption result = LivraisonController.getPlusRapide(orderId);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Doit retourner un transporteur');
        System.assertEquals('TransporteurB', result.nom, 'TransporteurB doit être le plus rapide');
        System.assertEquals(1, result.delai, 'Délai attendu : 1');
    }

    @IsTest
    static void testGetPlusRapide_aucunTransporteur_retourneNull() {
        Account particulier = [SELECT Id FROM Account WHERE TypeClient__c = 'Particulier' LIMIT 1];
        Order cmd = createOrder(particulier.Id, 'Suisse');

        Test.startTest();
        LivraisonController.TransporteurOption result = LivraisonController.getPlusRapide(cmd.Id);
        Test.stopTest();

        System.assertEquals(null, result, 'Doit retourner null — aucun transporteur Particulier en Suisse');
    }

    // ─────────────────────────────────────────────────────────────
    // getTransporteursCompatibles
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testGetTransporteursCompatibles_retourneListe() {
        Id orderId = getOrderId();
        Test.startTest();
        List<LivraisonController.TransporteurOption> results =
            LivraisonController.getTransporteursCompatibles(orderId);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Doit retourner 2 transporteurs compatibles');
        System.assert(results[0].prix <= results[1].prix, 'Doit être trié par prix croissant');
    }

    @IsTest
    static void testGetTransporteursCompatibles_aucunTransporteur_retourneListeVide() {
        Account particulier = [SELECT Id FROM Account WHERE TypeClient__c = 'Particulier' LIMIT 1];
        Order cmd = createOrder(particulier.Id, 'Luxembourg');

        Test.startTest();
        List<LivraisonController.TransporteurOption> results =
            LivraisonController.getTransporteursCompatibles(cmd.Id);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Doit retourner une liste vide — aucun transporteur au Luxembourg');
    }

    // ─────────────────────────────────────────────────────────────
    // lancerLivraison
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void testLancerLivraison_creeEnregistrementLivraison() {
        Id orderId        = getOrderId();
        Id transporteurId = getTransporteurId('TransporteurA');

        Test.startTest();
        LivraisonController.LivraisonResult result =
            LivraisonController.lancerLivraison(orderId, transporteurId);
        Test.stopTest();

        System.assertNotEquals(null, result.livraisonId, 'Un enregistrement Livraison__c doit être créé');

        Livraison__c livraison = [
            SELECT Statut__c, Order__c, Transporteur__c
            FROM   Livraison__c
            WHERE  Id = :result.livraisonId
        ];
        System.assertEquals(orderId,        livraison.Order__c,        'Commande liée correctement');
        System.assertEquals(transporteurId, livraison.Transporteur__c, 'Transporteur lié correctement');
        System.assert(
            livraison.Statut__c == 'En cours' || livraison.Statut__c == 'Échouée',
            'Statut doit être En cours ou Échouée'
        );
    }

    @IsTest
    static void testLancerLivraison_metAJourCommande() {
        Id orderId        = getOrderId();
        Id transporteurId = getTransporteurId('TransporteurA');

        Test.startTest();
        LivraisonController.lancerLivraison(orderId, transporteurId);
        Test.stopTest();

        Order cmd = [SELECT Transporteur__c, Statut_de_livraison__c FROM Order WHERE Id = :orderId];
        System.assertEquals(transporteurId, cmd.Transporteur__c, 'Transporteur mis à jour');
        System.assertNotEquals(null, cmd.Statut_de_livraison__c, 'Statut de livraison renseigné');
    }

    @IsTest
    static void testLancerLivraison_idInvalide_leveException() {
        Id fakeOrderId = [SELECT Id FROM Account LIMIT 1].Id;

        Boolean exceptionLevee = false;
        Test.startTest();
        try {
            LivraisonController.lancerLivraison(fakeOrderId, fakeOrderId);
        } catch (AuraHandledException e) {
            exceptionLevee = true;
        }
        Test.stopTest();

        System.assert(exceptionLevee, 'Une AuraHandledException doit être levée');
    }

    @IsTest
    static void testSimulerReponseTransporteur_retourneBoolean() {
        Test.startTest();
        Boolean result = LivraisonController.simulerReponseTransporteur();
        Test.stopTest();
        System.assert(result == true || result == false, 'Doit retourner un Boolean');
    }
}
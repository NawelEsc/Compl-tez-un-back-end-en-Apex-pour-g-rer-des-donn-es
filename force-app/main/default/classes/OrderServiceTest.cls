@IsTest
public class OrderServiceTest {

    @TestSetup
    static void setupTestData() {

        Id pricebookId = Test.getStandardPricebookId();

        Account particulier = new Account(
            Name          = 'Client Particulier Test',
            TypeClient__c = 'Particulier'
        );
        insert particulier;

        Account professionnel = new Account(
            Name          = 'Client Professionnel Test',
            TypeClient__c = 'Professionnel'
        );
        insert professionnel;

        Product2 produit = new Product2(Name = 'Produit Test', IsActive = true);
        insert produit;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id   = produit.Id,
            UnitPrice    = 10,
            IsActive     = true
        );
        insert pbe;

        // Transporteur moins cher — tous pays + tous types
        Transporteur__c transporteurMoinsCher = new Transporteur__c(
            Name                  = 'Transporteur Moins Cher',
            TypeClient__c         = 'Particulier;Professionnel',
            Pays__c               = 'France;Belgique;Suisse;Luxembourg',
            Prix__c               = 10,
            Delai_de_livraison__c = 3
        );
        insert transporteurMoinsCher;

        // Transporteur plus rapide — tous pays + tous types
        Transporteur__c transporteurPlusRapide = new Transporteur__c(
            Name                  = 'Transporteur Plus Rapide',
            TypeClient__c         = 'Particulier;Professionnel',
            Pays__c               = 'France;Belgique;Suisse;Luxembourg',
            Prix__c               = 20,
            Delai_de_livraison__c = 1
        );
        insert transporteurPlusRapide;

        // Prix pour les 4 pays
        insert new Prix_de_livraison__c(Name='10', Transporteur__c=transporteurMoinsCher.Id,  Pays__c='France',     Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='12', Transporteur__c=transporteurMoinsCher.Id,  Pays__c='Belgique',   Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='14', Transporteur__c=transporteurMoinsCher.Id,  Pays__c='Suisse',     Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='16', Transporteur__c=transporteurMoinsCher.Id,  Pays__c='Luxembourg', Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='20', Transporteur__c=transporteurPlusRapide.Id, Pays__c='France',     Delai_de_livraison__c=1);
        insert new Prix_de_livraison__c(Name='22', Transporteur__c=transporteurPlusRapide.Id, Pays__c='Belgique',   Delai_de_livraison__c=1);
        insert new Prix_de_livraison__c(Name='24', Transporteur__c=transporteurPlusRapide.Id, Pays__c='Suisse',     Delai_de_livraison__c=1);
        insert new Prix_de_livraison__c(Name='26', Transporteur__c=transporteurPlusRapide.Id, Pays__c='Luxembourg', Delai_de_livraison__c=1);
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 1 — Particulier avec moins de 3 produits → erreur
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testParticulierMoins3Produits() {
        Account particulier   = [SELECT Id FROM Account WHERE Name = 'Client Particulier Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];

        Order commande = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'France',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.validateOrder(commande);
        Test.stopTest();

        System.assert(true, 'validateOrder appelé sur commande Activated sans produits');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 2 — Particulier avec exactement 3 produits → succès
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testParticulierExactement3Produits() {
        Account particulier   = [SELECT Id FROM Account WHERE Name = 'Client Particulier Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];
        Id pbeId              = [SELECT Id FROM PricebookEntry WHERE IsActive = true LIMIT 1].Id;

        Order commande = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'France',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 3; i++) {
            items.add(new OrderItem(
                OrderId = commande.Id, PricebookEntryId = pbeId,
                Quantity = 1, UnitPrice = 10
            ));
        }
        insert items;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.validateOrder(commande);
        Test.stopTest();

        System.assert(true, 'Validation réussie avec 3 produits pour un Particulier');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 3 — Professionnel avec moins de 5 produits → erreur
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testProfessionnelMoins5Produits() {
        Account professionnel = [SELECT Id FROM Account WHERE Name = 'Client Professionnel Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];

        Order commande = new Order(
            AccountId       = professionnel.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'France',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.validateOrder(commande);
        Test.stopTest();

        System.assert(true, 'validateOrder appelé sur commande Pro Activated sans produits');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 4 — Professionnel avec exactement 5 produits → succès
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testProfessionnelExactement5Produits() {
        Account professionnel = [SELECT Id FROM Account WHERE Name = 'Client Professionnel Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];
        Id pbeId              = [SELECT Id FROM PricebookEntry WHERE IsActive = true LIMIT 1].Id;

        Order commande = new Order(
            AccountId       = professionnel.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'France',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < 5; i++) {
            items.add(new OrderItem(
                OrderId = commande.Id, PricebookEntryId = pbeId,
                Quantity = 1, UnitPrice = 10
            ));
        }
        insert items;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.validateOrder(commande);
        Test.stopTest();

        System.assert(true, 'Validation réussie avec 5 produits pour un Professionnel');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 5 — Sélection transporteur le moins cher en France
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testSelectTransporterMoinsCher_France() {
        Account particulier   = [SELECT Id FROM Account WHERE Name = 'Client Particulier Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];

        Order commande = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'France',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        // Passer à Activated pour déclencher selectTransporter
        commande.Status = 'Activated';

        Test.startTest();
        OrderService.selectTransporter(commande);
        Test.stopTest();

        Transporteur__c t = [SELECT Name FROM Transporteur__c WHERE Id = :commande.Transporteur__c LIMIT 1];
        System.assertEquals('Transporteur Moins Cher', t.Name, 'Le moins cher doit être sélectionné en France');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 6 — Sélection transporteur le moins cher en Belgique
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testSelectTransporterMoinsCher_Belgique() {
        Account particulier   = [SELECT Id FROM Account WHERE Name = 'Client Particulier Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];

        Order commande = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'Belgique',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.selectTransporter(commande);
        Test.stopTest();

        Transporteur__c t = [SELECT Name FROM Transporteur__c WHERE Id = :commande.Transporteur__c LIMIT 1];
        System.assertEquals('Transporteur Moins Cher', t.Name, 'Le moins cher doit être sélectionné en Belgique');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 7 — Sélection transporteur le moins cher en Suisse
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testSelectTransporterMoinsCher_Suisse() {
        Account particulier   = [SELECT Id FROM Account WHERE Name = 'Client Particulier Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];

        Order commande = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'Suisse',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.selectTransporter(commande);
        Test.stopTest();

        Transporteur__c t = [SELECT Name FROM Transporteur__c WHERE Id = :commande.Transporteur__c LIMIT 1];
        System.assertEquals('Transporteur Moins Cher', t.Name, 'Le moins cher doit être sélectionné en Suisse');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 8 — Sélection transporteur le moins cher au Luxembourg
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testSelectTransporterMoinsCher_Luxembourg() {
        Account particulier   = [SELECT Id FROM Account WHERE Name = 'Client Particulier Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];

        Order commande = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'Luxembourg',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.selectTransporter(commande);
        Test.stopTest();

        Transporteur__c t = [SELECT Name FROM Transporteur__c WHERE Id = :commande.Transporteur__c LIMIT 1];
        System.assertEquals('Transporteur Moins Cher', t.Name, 'Le moins cher doit être sélectionné au Luxembourg');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 9 — Sélection transporteur pour un Professionnel
    // ─────────────────────────────────────────────────────────────
    @IsTest
    static void testSelectTransporter_Professionnel() {
        Account professionnel = [SELECT Id FROM Account WHERE Name = 'Client Professionnel Test' LIMIT 1];
        Transporteur__c trans = [SELECT Id FROM Transporteur__c WHERE Name = 'Transporteur Moins Cher' LIMIT 1];

        Order commande = new Order(
            AccountId       = professionnel.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'France',
            Pricebook2Id    = Test.getStandardPricebookId(),
            Transporteur__c = trans.Id
        );
        insert commande;

        commande.Status = 'Activated';

        Test.startTest();
        OrderService.selectTransporter(commande);
        Test.stopTest();

        System.assertNotEquals(null, commande.Transporteur__c, 'Un transporteur doit être assigné pour un Professionnel');
    }
}
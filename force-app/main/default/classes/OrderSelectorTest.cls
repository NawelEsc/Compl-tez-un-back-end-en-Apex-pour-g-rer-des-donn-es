@IsTest
public class OrderSelectorTest {

    @TestSetup
    static void setupTestData() {

        Id pricebookId = Test.getStandardPricebookId();

        Account particulier = new Account(
            Name          = 'Compte Particulier Test',
            TypeClient__c = 'Particulier'
        );
        insert particulier;

        Account professionnel = new Account(
            Name          = 'Compte Professionnel Test',
            TypeClient__c = 'Professionnel'
        );
        insert professionnel;

        Transporteur__c transporteur = new Transporteur__c(
            Name                  = 'Transporteur Test',
            TypeClient__c         = 'Particulier;Professionnel',
            Pays__c               = 'France;Belgique;Suisse;Luxembourg',
            Prix__c               = 10,
            Delai_de_livraison__c = 2
        );
        insert transporteur;

        insert new Prix_de_livraison__c(Name='10', Transporteur__c=transporteur.Id, Pays__c='France',     Delai_de_livraison__c=2);
        insert new Prix_de_livraison__c(Name='12', Transporteur__c=transporteur.Id, Pays__c='Belgique',   Delai_de_livraison__c=2);
        insert new Prix_de_livraison__c(Name='14', Transporteur__c=transporteur.Id, Pays__c='Suisse',     Delai_de_livraison__c=2);
        insert new Prix_de_livraison__c(Name='16', Transporteur__c=transporteur.Id, Pays__c='Luxembourg', Delai_de_livraison__c=2);

        Product2 produit = new Product2(Name = 'Produit Test', IsActive = true);
        insert produit;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id   = produit.Id,
            UnitPrice    = 10,
            IsActive     = true
        );
        insert pbe;

        // Commande Particulier France — Draft → trigger ne valide pas
        Order cmdParticulierFrance = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'France',
            Pricebook2Id    = pricebookId,
            Transporteur__c = transporteur.Id
        );
        insert cmdParticulierFrance;

        List<OrderItem> items3 = new List<OrderItem>();
        for (Integer i = 0; i < 3; i++) {
            items3.add(new OrderItem(
                OrderId = cmdParticulierFrance.Id, PricebookEntryId = pbe.Id,
                Quantity = 1, UnitPrice = 10
            ));
        }
        insert items3;

        // Commande Professionnel Belgique — Draft
        Order cmdProfessionnelBelgique = new Order(
            AccountId       = professionnel.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'Belgique',
            Pricebook2Id    = pricebookId,
            Transporteur__c = transporteur.Id
        );
        insert cmdProfessionnelBelgique;

        List<OrderItem> items5 = new List<OrderItem>();
        for (Integer i = 0; i < 5; i++) {
            items5.add(new OrderItem(
                OrderId = cmdProfessionnelBelgique.Id, PricebookEntryId = pbe.Id,
                Quantity = 1, UnitPrice = 10
            ));
        }
        insert items5;

        // Commande Particulier Suisse — Draft — 0 produits (trigger ne bloque pas)
        Order cmdSuisse = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'Suisse',
            Pricebook2Id    = pricebookId,
            Transporteur__c = transporteur.Id
        );
        insert cmdSuisse;

        // Commande Particulier Luxembourg — Draft — 0 produits
        Order cmdLuxembourg = new Order(
            AccountId       = particulier.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            Pays__c         = 'Luxembourg',
            Pricebook2Id    = pricebookId,
            Transporteur__c = transporteur.Id
        );
        insert cmdLuxembourg;
    }

    @IsTest
    static void testCountOrderItems_3Produits_France() {
        Order commande = [SELECT Id FROM Order
                          WHERE Account.TypeClient__c = 'Particulier'
                          AND Pays__c = 'France' LIMIT 1];
        Test.startTest();
        Integer count = OrderSelector.countOrderItems(commande.Id);
        Test.stopTest();
        System.assertEquals(3, count, 'Le nombre de produits doit être 3 pour un Particulier en France');
    }

    @IsTest
    static void testCountOrderItems_5Produits_Belgique() {
        Order commande = [SELECT Id FROM Order
                          WHERE Account.TypeClient__c = 'Professionnel'
                          AND Pays__c = 'Belgique' LIMIT 1];
        Test.startTest();
        Integer count = OrderSelector.countOrderItems(commande.Id);
        Test.stopTest();
        System.assertEquals(5, count, 'Le nombre de produits doit être 5 pour un Professionnel en Belgique');
    }

    @IsTest
    static void testCountOrderItems_Vide_Suisse() {
        Order commande = [SELECT Id FROM Order WHERE Pays__c = 'Suisse' LIMIT 1];
        Test.startTest();
        Integer count = OrderSelector.countOrderItems(commande.Id);
        Test.stopTest();
        System.assertEquals(0, count, 'Une commande vide en Suisse doit retourner 0');
    }

    @IsTest
    static void testCountOrderItems_Vide_Luxembourg() {
        Order commande = [SELECT Id FROM Order WHERE Pays__c = 'Luxembourg' LIMIT 1];
        Test.startTest();
        Integer count = OrderSelector.countOrderItems(commande.Id);
        Test.stopTest();
        System.assertEquals(0, count, 'Une commande vide au Luxembourg doit retourner 0');
    }
}
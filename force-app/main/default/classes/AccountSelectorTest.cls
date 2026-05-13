@isTest
public class AccountSelectorTest {

    @TestSetup
    static void setupTestData() {

        // Créer un compte Particulier
        Account particulier = new Account(
            Name = 'Compte Particulier Test',
            TypeClient__c = 'Particulier'
        );
        insert particulier;

        // Créer un compte Professionnel
        Account professionnel = new Account(
            Name = 'Compte Professionnel Test',
            TypeClient__c = 'Professionnel'
        );
        insert professionnel;

        // Créer un transporteur compatible avec tous les pays
        Transporteur__c transporteur = new Transporteur__c(
            Name = 'Transporteur Test',
            TypeClient__c = 'Particulier;Professionnel',
            Pays__c = 'France;Belgique;Suisse;Luxembourg'
        );
        insert transporteur;

        // Créer une commande liée au compte Particulier
        Order commande = new Order(
            AccountId = particulier.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pays__c = 'France',
            Pricebook2Id = Test.getStandardPricebookId(),
            Transporteur__c = transporteur.Id
        );
        insert commande;
    }

    // TEST 1 - Récupérer un compte Particulier par son Id
    // Vérifie que getAccountById retourne bien le compte avec TypeClient__c = Particulier
    @isTest
    static void testGetAccountById_Particulier() {
        Account particulier = [SELECT Id FROM Account 
                               WHERE Name = 'Compte Particulier Test' LIMIT 1];
        Test.startTest();
        Account result = AccountSelector.getAccountById(particulier.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 
            'Le compte doit être trouvé');
        System.assertEquals('Compte Particulier Test', result.Name, 
            'Le nom doit correspondre');
        System.assertEquals('Particulier', result.TypeClient__c, 
            'Le type client doit être Particulier');
    }

    // TEST 2 - Récupérer un compte Professionnel par son Id
    // Vérifie que getAccountById retourne bien le compte avec TypeClient__c = Professionnel
    @isTest
    static void testGetAccountById_Professionnel() {
        Account professionnel = [SELECT Id FROM Account 
                                 WHERE Name = 'Compte Professionnel Test' LIMIT 1];
        Test.startTest();
        Account result = AccountSelector.getAccountById(professionnel.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 
            'Le compte doit être trouvé');
        System.assertEquals('Compte Professionnel Test', result.Name, 
            'Le nom doit correspondre');
        System.assertEquals('Professionnel', result.TypeClient__c, 
            'Le type client doit être Professionnel');
    }

    // TEST 3 - Récupérer le compte lié à une commande
    // Vérifie que getAccountByOrderId remonte bien le compte associé à la commande
    @isTest
    static void testGetAccountByOrderId() {
        Order commande = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        Account result = AccountSelector.getAccountByOrderId(commande.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 
            'Le compte doit être trouvé');
        System.assertEquals('Compte Particulier Test', result.Name, 
            'Le compte lié à la commande doit être le Particulier');
        System.assertEquals('Particulier', result.TypeClient__c, 
            'Le type client doit être Particulier');
    }
}
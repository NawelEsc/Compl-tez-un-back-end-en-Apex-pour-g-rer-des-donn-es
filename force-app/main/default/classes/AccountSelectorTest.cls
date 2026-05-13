@isTest
public class AccountSelectorTest {

    @TestSetup
    static void setupTestData() {

        Account particulier = new Account(
            Name = 'Compte Particulier Test',
            TypeClient__c = 'Particulier'
        );
        insert particulier;

        Account professionnel = new Account(
            Name = 'Compte Professionnel Test',
            TypeClient__c = 'Professionnel'
        );
        insert professionnel;

        Transporteur__c transporteur = new Transporteur__c(
            Name = 'Transporteur Test',
            TypeClient__c = 'Particulier;Professionnel',
            Pays__c = 'France;Belgique;Suisse;Luxembourg'
        );
        insert transporteur;

        // Prix de livraison pour que le trigger ne bloque pas
        Prix_de_livraison__c prix = new Prix_de_livraison__c(
            Name = '10',
            Transporteur__c = transporteur.Id,
            Pays__c = 'France',
            Delai_de_livraison__c = 2
        );
        insert prix;

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

    @isTest
    static void testGetAccountById_Particulier() {
        Account particulier = [SELECT Id FROM Account 
                               WHERE Name = 'Compte Particulier Test' LIMIT 1];
        Test.startTest();
        Account result = AccountSelector.getAccountById(particulier.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Le compte doit être trouvé');
        System.assertEquals('Compte Particulier Test', result.Name, 'Le nom doit correspondre');
        System.assertEquals('Particulier', result.TypeClient__c, 'Le type doit être Particulier');
    }

    @isTest
    static void testGetAccountById_Professionnel() {
        Account professionnel = [SELECT Id FROM Account 
                                 WHERE Name = 'Compte Professionnel Test' LIMIT 1];
        Test.startTest();
        Account result = AccountSelector.getAccountById(professionnel.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Le compte doit être trouvé');
        System.assertEquals('Compte Professionnel Test', result.Name, 'Le nom doit correspondre');
        System.assertEquals('Professionnel', result.TypeClient__c, 'Le type doit être Professionnel');
    }

    @isTest
    static void testGetAccountByOrderId() {
        Order commande = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        Account result = AccountSelector.getAccountByOrderId(commande.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'Le compte doit être trouvé');
        System.assertEquals('Compte Particulier Test', result.Name, 'Le compte doit être le particulier');
        System.assertEquals('Particulier', result.TypeClient__c, 'Le type doit être Particulier');
    }
}
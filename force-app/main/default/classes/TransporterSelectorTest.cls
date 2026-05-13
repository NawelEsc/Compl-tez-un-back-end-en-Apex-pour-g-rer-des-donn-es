@isTest
public class TransporterSelectorTest {

    @TestSetup
    static void setupTestData() {

        // Transporteur Particulier - moins cher
        Transporteur__c t1 = new Transporteur__c(
            Name = 'Transporteur Particulier Moins Cher',
            TypeClient__c = 'Particulier',
            Pays__c = 'France;Belgique;Suisse;Luxembourg'
        );
        insert t1;

        // Transporteur Particulier - plus rapide
        Transporteur__c t2 = new Transporteur__c(
            Name = 'Transporteur Particulier Plus Rapide',
            TypeClient__c = 'Particulier',
            Pays__c = 'France;Belgique;Suisse;Luxembourg'
        );
        insert t2;

        // Transporteur Professionnel
        Transporteur__c t3 = new Transporteur__c(
            Name = 'Transporteur Professionnel',
            TypeClient__c = 'Professionnel',
            Pays__c = 'France;Belgique;Suisse;Luxembourg'
        );
        insert t3;

        // Prix moins cher pour les 4 pays
        insert new Prix_de_livraison__c(Name='10', Transporteur__c=t1.Id, Pays__c='France', Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='12', Transporteur__c=t1.Id, Pays__c='Belgique', Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='14', Transporteur__c=t1.Id, Pays__c='Suisse', Delai_de_livraison__c=3);
        insert new Prix_de_livraison__c(Name='16', Transporteur__c=t1.Id, Pays__c='Luxembourg', Delai_de_livraison__c=3);

        // Prix plus rapide pour les 4 pays
        insert new Prix_de_livraison__c(Name='30', Transporteur__c=t2.Id, Pays__c='France', Delai_de_livraison__c=1);
        insert new Prix_de_livraison__c(Name='32', Transporteur__c=t2.Id, Pays__c='Belgique', Delai_de_livraison__c=1);
        insert new Prix_de_livraison__c(Name='34', Transporteur__c=t2.Id, Pays__c='Suisse', Delai_de_livraison__c=1);
        insert new Prix_de_livraison__c(Name='36', Transporteur__c=t2.Id, Pays__c='Luxembourg', Delai_de_livraison__c=1);

        // Prix professionnel pour les 4 pays
        insert new Prix_de_livraison__c(Name='20', Transporteur__c=t3.Id, Pays__c='France', Delai_de_livraison__c=2);
        insert new Prix_de_livraison__c(Name='22', Transporteur__c=t3.Id, Pays__c='Belgique', Delai_de_livraison__c=2);
        insert new Prix_de_livraison__c(Name='24', Transporteur__c=t3.Id, Pays__c='Suisse', Delai_de_livraison__c=2);
        insert new Prix_de_livraison__c(Name='26', Transporteur__c=t3.Id, Pays__c='Luxembourg', Delai_de_livraison__c=2);
    }

    // TEST 1 - Moins cher Particulier France
    @isTest
    static void testGetCheapestTransporter_Particulier_France() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getCheapestTransporter('France', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals('10', result.Name, 'Le moins cher en France doit être 10');
    }

    // TEST 2 - Moins cher Particulier Belgique
    @isTest
    static void testGetCheapestTransporter_Particulier_Belgique() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getCheapestTransporter('Belgique', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals('12', result.Name, 'Le moins cher en Belgique doit être 12');
    }

    // TEST 3 - Moins cher Particulier Suisse
    @isTest
    static void testGetCheapestTransporter_Particulier_Suisse() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getCheapestTransporter('Suisse', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals('14', result.Name, 'Le moins cher en Suisse doit être 14');
    }

    // TEST 4 - Moins cher Particulier Luxembourg
    @isTest
    static void testGetCheapestTransporter_Particulier_Luxembourg() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getCheapestTransporter('Luxembourg', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals('16', result.Name, 'Le moins cher au Luxembourg doit être 16');
    }

    // TEST 5 - Plus rapide Particulier France
    @isTest
    static void testGetFastestTransporter_Particulier_France() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getFastestTransporter('France', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals(1, result.Delai_de_livraison__c, 'Le plus rapide en France doit avoir délai 1');
    }

    // TEST 6 - Plus rapide Particulier Belgique
    @isTest
    static void testGetFastestTransporter_Particulier_Belgique() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getFastestTransporter('Belgique', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals(1, result.Delai_de_livraison__c, 'Le plus rapide en Belgique doit avoir délai 1');
    }

    // TEST 7 - Plus rapide Particulier Suisse
    @isTest
    static void testGetFastestTransporter_Particulier_Suisse() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getFastestTransporter('Suisse', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals(1, result.Delai_de_livraison__c, 'Le plus rapide en Suisse doit avoir délai 1');
    }

    // TEST 8 - Plus rapide Particulier Luxembourg
    @isTest
    static void testGetFastestTransporter_Particulier_Luxembourg() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getFastestTransporter('Luxembourg', 'Particulier');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals(1, result.Delai_de_livraison__c, 'Le plus rapide au Luxembourg doit avoir délai 1');
    }

    // TEST 9 - Moins cher Professionnel France
    @isTest
    static void testGetCheapestTransporter_Professionnel_France() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getCheapestTransporter('France', 'Professionnel');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Un transporteur doit être trouvé');
        System.assertEquals('20', result.Name, 'Le moins cher professionnel en France doit être 20');
    }

    // TEST 10 - Transporteurs compatibles Particulier France
    @isTest
    static void testGetCompatibleTransporters_Particulier_France() {
        Test.startTest();
        List<Prix_de_livraison__c> results = TransporterSelector.getCompatibleTransporters('France', 'Particulier');
        Test.stopTest();
        System.assertEquals(2, results.size(), 'Deux transporteurs particuliers doivent être trouvés en France');
    }

    // TEST 11 - Transporteurs compatibles Professionnel France
    @isTest
    static void testGetCompatibleTransporters_Professionnel_France() {
        Test.startTest();
        List<Prix_de_livraison__c> results = TransporterSelector.getCompatibleTransporters('France', 'Professionnel');
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Un transporteur professionnel doit être trouvé en France');
    }

    // TEST 12 - Pays inexistant → aucun résultat
    @isTest
    static void testGetCheapestTransporter_PaysInexistant() {
        Test.startTest();
        Prix_de_livraison__c result = TransporterSelector.getCheapestTransporter('Allemagne', 'Particulier');
        Test.stopTest();
        System.assertEquals(null, result, 'Aucun transporteur pour un pays inexistant');
    }

    // TEST 13 - Pays inexistant liste vide
    @isTest
    static void testGetCompatibleTransporters_PaysInexistant() {
        Test.startTest();
        List<Prix_de_livraison__c> results = TransporterSelector.getCompatibleTransporters('Allemagne', 'Particulier');
        Test.stopTest();
        System.assertEquals(0, results.size(), 'Aucun transporteur pour un pays inexistant');
    }
}
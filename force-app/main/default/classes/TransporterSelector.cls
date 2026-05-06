public with sharing class TransporterSelector {

    public static Transporteur__c getCheapestTransporter(
                                    String pays, String typeClient) {
        List<Transporteur__c> transporteurs = [
            SELECT Id, Name, TypeClient__c,
                   Prix__c, Delai_de_livraison__c
            FROM Transporteur__c
            WHERE Pays__c INCLUDES (:pays)
            AND TypeClient__c INCLUDES (:typeClient)
            ORDER BY Prix__c ASC
            LIMIT 1
        ];
        return transporteurs.isEmpty() ? null : transporteurs[0];
    }

    public static Transporteur__c getFastestTransporter(
                                    String pays, String typeClient) {
        List<Transporteur__c> transporteurs = [
            SELECT Id, Name, TypeClient__c,
                   Prix__c, Delai_de_livraison__c
            FROM Transporteur__c
            WHERE Pays__c INCLUDES (:pays)
            AND TypeClient__c INCLUDES (:typeClient)
            ORDER BY Delai_de_livraison__c ASC
            LIMIT 1
        ];
        return transporteurs.isEmpty() ? null : transporteurs[0];
    }

    public static List<Transporteur__c> getCompatibleTransporters(
                                         String pays, String typeClient) {
        return [
            SELECT Id, Name, TypeClient__c,
                   Prix__c, Delai_de_livraison__c
            FROM Transporteur__c
            WHERE Pays__c INCLUDES (:pays)
            AND TypeClient__c INCLUDES (:typeClient)
            ORDER BY Prix__c ASC
        ];
    }
}
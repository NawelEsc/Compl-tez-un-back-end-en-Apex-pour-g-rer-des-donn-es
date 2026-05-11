public with sharing class TransporterSelector {

    public static Prix_de_livraison__c getCheapestTransporter(
                                        String pays, String typeClient) {
        List<Prix_de_livraison__c> prix = [
            SELECT Id, Transporteur__c, Transporteur__r.Name,
                   Pays__c, Name, Delai_de_livraison__c
            FROM Prix_de_livraison__c
            WHERE Pays__c = :pays
            AND Transporteur__r.TypeClient__c INCLUDES (:typeClient)
        ];
        Prix_de_livraison__c cheapest = null;
        Integer minPrix = 999999;
        for (Prix_de_livraison__c p : prix) {
            Integer prixVal = Integer.valueOf(p.Name);
            if (prixVal < minPrix) {
                minPrix = prixVal;
                cheapest = p;
            }
        }
        return cheapest;
    }

    public static Prix_de_livraison__c getFastestTransporter(
                                        String pays, String typeClient) {
        List<Prix_de_livraison__c> prix = [
            SELECT Id, Transporteur__c, Transporteur__r.Name,
                   Pays__c, Name, Delai_de_livraison__c
            FROM Prix_de_livraison__c
            WHERE Pays__c = :pays
            AND Transporteur__r.TypeClient__c INCLUDES (:typeClient)
            ORDER BY Delai_de_livraison__c ASC
            LIMIT 1
        ];
        return prix.isEmpty() ? null : prix[0];
    }

    public static List<Prix_de_livraison__c> getCompatibleTransporters(
                                              String pays, String typeClient) {
        return [
            SELECT Id, Transporteur__c, Transporteur__r.Name,
                   Pays__c, Name, Delai_de_livraison__c
            FROM Prix_de_livraison__c
            WHERE Pays__c = :pays
            AND Transporteur__r.TypeClient__c INCLUDES (:typeClient)
        ];
    }
}
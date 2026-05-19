/**
 * @description Sélecteur pour les transporteurs et leurs tarifs de livraison.
 *              Fournit des méthodes de requêtes SOQL pour récupérer les transporteurs
 *              compatibles avec un pays et un type de client donné.
 *              Utilisé par OrderService pour la sélection automatique du transporteur.
 */
public with sharing class TransporterSelector {

    /**
     * @description Retourne le transporteur proposant le tarif le moins élevé
     *              pour un pays et un type de client donnés.
     *              La recherche du minimum est effectuée en mémoire car le champ
     *              Name stocke le prix sous forme de texte.
     * @param  pays        Pays de livraison (France, Belgique, Suisse, Luxembourg)
     * @param  typeClient  Type de client (Particulier ou Professionnel)
     * @return             Enregistrement Prix_de_livraison__c le moins cher, ou null si aucun trouvé
     */
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

    /**
     * @description Retourne le transporteur avec le délai de livraison le plus court
     *              pour un pays et un type de client donnés.
     *              Le tri est effectué directement en SOQL pour optimiser les performances.
     * @param  pays        Pays de livraison (France, Belgique, Suisse, Luxembourg)
     * @param  typeClient  Type de client (Particulier ou Professionnel)
     * @return             Enregistrement Prix_de_livraison__c le plus rapide, ou null si aucun trouvé
     */
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

    /**
     * @description Retourne tous les transporteurs compatibles avec un pays
     *              et un type de client donnés, sans restriction de prix ou de délai.
     *              Utilisé par le LWC pour afficher la liste complète des options disponibles.
     * @param  pays        Pays de livraison (France, Belgique, Suisse, Luxembourg)
     * @param  typeClient  Type de client (Particulier ou Professionnel)
     * @return             Liste de Prix_de_livraison__c compatibles (peut être vide)
     */
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
/**
 * @description Sélecteur pour l'objet Account.
 *              Centralise toutes les requêtes SOQL liées aux comptes
 *              conformément à l'architecture en couches du projet LTP.
 *              Utilisé par OrderService pour récupérer le type de client
 *              associé à une commande.
 */
public with sharing class AccountSelector {

    /**
     * @description Récupère un compte Salesforce par son identifiant.
     *              Retourne les informations de base ainsi que le champ
     *              personnalisé TypeClient__c nécessaire à la logique métier.
     * @param  accountId  Id de l'enregistrement Account à récupérer
     * @return            Enregistrement Account correspondant
     */
    public static Account getAccountById(Id accountId) {
        return [
            SELECT Id, Name, Type, Industry, BillingCity,
                   BillingCountry, Phone, Website, TypeClient__c
            FROM Account
            WHERE Id = :accountId
        ];
    }

    /**
     * @description Récupère le compte associé à une commande donnée.
     *              Effectue deux requêtes SOQL : une pour récupérer l'AccountId
     *              depuis la commande, une autre pour récupérer le compte.
     * @param  orderId  Id de l'enregistrement Order
     * @return          Enregistrement Account lié à la commande
     */
    public static Account getAccountByOrderId(Id orderId) {
        Order order = [
            SELECT Id, AccountId
            FROM Order
            WHERE Id = :orderId
        ];
        return [
            SELECT Id, Name, TypeClient__c
            FROM Account
            WHERE Id = :order.AccountId
        ];
    }
}
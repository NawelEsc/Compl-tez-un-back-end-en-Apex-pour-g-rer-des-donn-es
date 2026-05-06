public with sharing class AccountSelector {

    // Récupérer un compte par son Id
    public static Account getAccountById(Id accountId) {
        return [
            SELECT Id, Name, Type, Industry, BillingCity, 
                   BillingCountry, Phone, Website, TypeClient__c
            FROM Account
            WHERE Id = :accountId
        ];
    }

    // Récupérer le compte lié à une commande
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
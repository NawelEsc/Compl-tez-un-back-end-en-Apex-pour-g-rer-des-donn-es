public with sharing class OrderService {

    public static void validateOrder(Order orderToValidate) {
        
        // Récupérer le compte lié à la commande
        Account account = AccountSelector.getAccountByOrderId(
                                            orderToValidate.Id);
        
        // Compter le nombre de produits de la commande
        Integer nbProduits = [
            SELECT COUNT() 
            FROM OrderItem 
            WHERE OrderId = :orderToValidate.Id
        ];
        
        // Vérifier le nombre minimum selon le type de client
        if (account.TypeClient__c == 'Particulier') {
            if (nbProduits < 3) {
                orderToValidate.addError(
                    'Une commande particulier doit avoir au moins 3 produits.'
                );
            }
        } else if (account.TypeClient__c == 'Professionnel') {
            if (nbProduits < 5) {
                orderToValidate.addError(
                    'Une commande professionnelle doit avoir au moins 5 produits.'
                );
            }
        }
    }

    public static void selectTransporter(Order orderToValidate) {
        
        // Récupérer le compte lié à la commande
        Account account = AccountSelector.getAccountByOrderId(
                                            orderToValidate.Id);
        
        // Récupérer le transporteur le moins cher
        Transporteur__c cheapest = TransporterSelector.getCheapestTransporter(
                                        orderToValidate.Pays__c,
                                        account.TypeClient__c);
        
        // Récupérer le transporteur le plus rapide
        Transporteur__c fastest = TransporterSelector.getFastestTransporter(
                                        orderToValidate.Pays__c,
                                        account.TypeClient__c);
        
        // Assigner le transporteur le moins cher par défaut
        if (cheapest != null) {
            orderToValidate.Transporteur__c = cheapest.Id;
        } else if (fastest != null) {
            orderToValidate.Transporteur__c = fastest.Id;
        } else {
            orderToValidate.addError(
                'Aucun transporteur disponible pour ce pays et ce type de client.'
            );
        }
    }
}
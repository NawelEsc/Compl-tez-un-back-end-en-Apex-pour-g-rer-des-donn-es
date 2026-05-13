public with sharing class OrderService {

    public static void validateOrder(Order orderToValidate) {

        // Récupérer le compte directement depuis AccountId de la commande
        Account account = AccountSelector.getAccountById(orderToValidate.AccountId);

        // Compter les produits via OrderSelector
        Integer numberOfProducts = OrderSelector.countOrderItems(orderToValidate.Id);

        // Valider selon le type de client
        if (account.TypeClient__c == 'Particulier' && numberOfProducts < 3) {
            orderToValidate.addError(
                'Pour les particuliers, les commandes avec moins de 3 produits sont refusées.'
            );
        } else if (account.TypeClient__c == 'Professionnel' && numberOfProducts < 5) {
            orderToValidate.addError(
                'Pour les professionnels, les commandes avec moins de 5 produits sont refusées.'
            );
        }
    }

    public static void selectTransporter(Order orderToValidate) {

        // Récupérer le compte directement depuis AccountId de la commande
        Account account = AccountSelector.getAccountById(orderToValidate.AccountId);

        // Récupérer le moins cher et le plus rapide
        Prix_de_livraison__c cheapestTransporter = TransporterSelector.getCheapestTransporter(
                                            orderToValidate.Pays__c,
                                            account.TypeClient__c);

        Prix_de_livraison__c fastestTransporter = TransporterSelector.getFastestTransporter(
                                            orderToValidate.Pays__c,
                                            account.TypeClient__c);

        // Assigner le transporteur à la commande
        if (cheapestTransporter != null) {
            orderToValidate.Transporteur__c = cheapestTransporter.Transporteur__c;
        } else if (fastestTransporter != null) {
            orderToValidate.Transporteur__c = fastestTransporter.Transporteur__c;
        } else {
            orderToValidate.addError(
                'Aucun transporteur disponible pour ce pays et ce type de client.'
            );
        }
    }
}
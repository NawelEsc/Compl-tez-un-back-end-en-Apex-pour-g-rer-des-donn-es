public with sharing class OrderService {

    public static void validateOrder(Order orderToValidate) {

        // Récupérer le compte associé à la commande
        Account account = AccountSelector.getAccountByOrderId(
                                            orderToValidate.Id);

        // Compter les produits via OrderSelector
        Integer numberOfProducts = OrderSelector.countOrderItems(
                                            orderToValidate.Id);

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

        // Récupérer le compte associé à la commande
        Account account = AccountSelector.getAccountByOrderId(
                                            orderToValidate.Id);

        // Récupérer le prix de livraison le moins cher et le plus rapide
        Prix_de_livraison__c cheapestDeliveryPrice = TransporterSelector.getCheapestTransporter(
                                            orderToValidate.Pays__c,
                                            account.TypeClient__c);

        Prix_de_livraison__c fastestDeliveryPrice = TransporterSelector.getFastestTransporter(
                                            orderToValidate.Pays__c,
                                            account.TypeClient__c);

        // Assigner le transporteur à la commande
        if (cheapestDeliveryPrice != null) {
            orderToValidate.Transporteur__c = cheapestDeliveryPrice.Transporteur__c;
        } else if (fastestDeliveryPrice != null) {
            orderToValidate.Transporteur__c = fastestDeliveryPrice.Transporteur__c;
        } else {
            orderToValidate.addError(
                'Aucun transporteur disponible pour ce pays et ce type de client.'
            );
        }
    }
}
trigger OrderTrigger on Order (before insert, before update) {
    for (Order order : Trigger.new) {
        // Valider le nombre minimum de produits
        OrderService.validateOrder(order);
        // Sélectionner automatiquement le meilleur transporteur
        OrderService.selectTransporter(order);
    }
}
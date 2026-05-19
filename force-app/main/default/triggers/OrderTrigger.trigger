/**
 * @description Déclencheur sur l'objet Order.
 *              S'exécute avant l'insertion et la mise à jour d'une commande.
 *              Délègue la logique métier à OrderService conformément aux
 *              bonnes pratiques Salesforce (trigger léger, logique dans le service).
 *
 *              Actions effectuées :
 *              1. Validation du nombre minimum de produits (uniquement si Activated)
 *              2. Sélection automatique du transporteur optimal (uniquement si Activated)
 */
trigger OrderTrigger on Order (before insert, before update) {
    for (Order order : Trigger.new) {
        // Valider le nombre minimum de produits selon le type de client
        OrderService.validateOrder(order);
        // Sélectionner automatiquement le transporteur le moins cher compatible
        OrderService.selectTransporter(order);
    }
}
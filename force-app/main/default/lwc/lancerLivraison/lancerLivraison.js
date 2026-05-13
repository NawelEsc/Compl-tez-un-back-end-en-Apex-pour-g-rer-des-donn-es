import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasLivraisonPermission from '@salesforce/customPermission/Acces_Livraison';

import getMoinsCher from '@salesforce/apex/LivraisonController.getMoinsCher';
import getPlusRapide from '@salesforce/apex/LivraisonController.getPlusRapide';
import getTransporteursCompatibles from '@salesforce/apex/LivraisonController.getTransporteursCompatibles';
import lancerLivraisonApex from '@salesforce/apex/LivraisonController.lancerLivraison';

const CARD_BASE = 'slds-box slds-box_x-small slds-theme_default option-card';
const CARD_SELECTED = CARD_BASE + ' option-card_selected';

export default class LancerLivraison extends LightningElement {

    @api recordId;

    @track moinsCher = null;
    @track plusRapide = null;
    @track transporteurs = [];
    @track transporteurSelectionneId = null;
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track showResultat = false;
    @track messageResultat = '';
    @track livraisonSucces = false;

    _selectedType = null;

    connectedCallback() {
        if (!hasLivraisonPermission) {
            this.hasError = true;
            this.errorMessage = 'Vous n\'avez pas les permissions nécessaires.';
            this.isLoading = false;
            return;
        }
        this._chargerDonnees();
    }

    async _chargerDonnees() {
        this.isLoading = true;
        this.hasError = false;
        try {
            const [moinsCher, plusRapide, transporteurs] = await Promise.all([
                getMoinsCher({ orderId: this.recordId }),
                getPlusRapide({ orderId: this.recordId }),
                getTransporteursCompatibles({ orderId: this.recordId })
            ]);
            this.moinsCher = moinsCher;
            this.plusRapide = plusRapide;
            this.transporteurs = transporteurs || [];
            if (this.moinsCher) {
                this.transporteurSelectionneId = this.moinsCher.transporteurId;
                this._selectedType = 'moinsCher';
            }
        } catch (error) {
            this.hasError = true;
            this.errorMessage = error.body?.message || 'Erreur lors du chargement.';
        } finally {
            this.isLoading = false;
        }
    }

    selectMoinsCher() {
        if (!this.moinsCher) return;
        this.transporteurSelectionneId = this.moinsCher.transporteurId;
        this._selectedType = 'moinsCher';
        this._resetResultat();
    }

    selectPlusRapide() {
        if (!this.plusRapide) return;
        this.transporteurSelectionneId = this.plusRapide.transporteurId;
        this._selectedType = 'plusRapide';
        this._resetResultat();
    }

    handleKeyMoinsCher(event) {
        if (event.key === 'Enter' || event.key === ' ') this.selectMoinsCher();
    }

    handleKeyPlusRapide(event) {
        if (event.key === 'Enter' || event.key === ' ') this.selectPlusRapide();
    }

    handleTransporteurChange(event) {
        this.transporteurSelectionneId = event.detail.value;
        this._selectedType = 'manuel';
        this._resetResultat();
    }

    async lancerLivraison() {
        if (!this.transporteurSelectionneId) return;
        this.isLoading = true;
        this.showResultat = false;
        try {
            const result = await lancerLivraisonApex({
                orderId: this.recordId,
                transporteurId: this.transporteurSelectionneId
            });
            this.livraisonSucces = result.succes;
            this.messageResultat = result.message;
            this.showResultat = true;
            this.dispatchEvent(new ShowToastEvent({
                title: result.succes ? 'Livraison lancée' : 'Échec',
                message: result.message,
                variant: result.succes ? 'success' : 'error'
            }));
        } catch (error) {
            this.livraisonSucces = false;
            this.messageResultat = error.body?.message || 'Erreur inattendue.';
            this.showResultat = true;
        } finally {
            this.isLoading = false;
        }
    }

    get aucunTransporteur() {
        return !this.isLoading && this.transporteurs.length === 0;
    }

    get transporteurSelectionne() {
        if (!this.transporteurSelectionneId) return null;
        return this.transporteurs.find(t => t.transporteurId === this.transporteurSelectionneId) || null;
    }

    get optionsTransporteurs() {
        return this.transporteurs.map(t => ({
            label: `${t.nom} — ${t.prix} € — ${t.delai} j`,
            value: t.transporteurId
        }));
    }

    get boutonDisabled() {
        return !this.transporteurSelectionneId || this.isLoading;
    }

    get classMoinsCher() {
        return this._selectedType === 'moinsCher' ? CARD_SELECTED : CARD_BASE;
    }

    get classPlusRapide() {
        return this._selectedType === 'plusRapide' ? CARD_SELECTED : CARD_BASE;
    }

    get classeResultat() {
        const base = 'slds-notify slds-notify_alert';
        return this.livraisonSucces ? `${base} slds-alert_success` : `${base} slds-alert_error`;
    }

    get iconeResultat() {
        return this.livraisonSucces ? 'utility:success' : 'utility:error';
    }

    _resetResultat() {
        this.showResultat = false;
        this.messageResultat = '';
    }
}
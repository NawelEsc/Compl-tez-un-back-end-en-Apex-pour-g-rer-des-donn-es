import { createElement } from '@lwc/engine-dom';
import LancerLivraison from 'c/lancerLivraison';

describe('c-lancer-livraison', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('le composant se charge sans erreur', () => {
        const element = createElement('c-lancer-livraison', {
            is: LancerLivraison
        });
        document.body.appendChild(element);
        expect(element).toBeTruthy();
    });
});
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import { LightningElement, wire } from 'lwc';

export default class BoatSearchResults extends LightningElement {
    boats = [];
    boatTypeId = "";

    @wire(getBoats, { boatTypeId: "$boatTypeId" })
    wireBoats({ data, error }) {
        if (data)
            this.boats = data
        else if (error)
            console.log('error', error)
    }

    updateSelectedTile({ detail }) {
        this.boatTypeId = detail.boatId;
    }
}
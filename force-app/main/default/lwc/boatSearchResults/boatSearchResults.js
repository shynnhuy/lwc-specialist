/* eslint-disable @lwc/lwc/no-api-reassignments */
import getBoats from "@salesforce/apex/BoatDataService.getBoats";
import { LightningElement, api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { MessageContext, publish } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import BOATMC from "@salesforce/messageChannel/BoatMessageChannel__c";
import updateBoatList from "@salesforce/apex/BoatDataService.updateBoatList";

const SUCCESS_TITLE = "Success";
const MESSAGE_SHIP_IT = "Ship it!";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error";
const ERROR_VARIANT = "error";

export default class BoatSearchResults extends LightningElement {
  @api selectedBoatId;
  @track boats;

  boatTypeId = "";

  isLoading = false;

  columns = [
    { label: "Name", fieldName: "Name", editable: true },
    { label: "Length", fieldName: "Length__c", type: "number" },
    { label: "Price", fieldName: "Price__c", type: "currency" },
    { label: "Description", fieldName: "Description__c" }
  ];

  @track draftValues = [];

  @wire(MessageContext) messageContext;

  @wire(getBoats, { boatTypeId: "$boatTypeId" })
  wiredBoats({ data, error }) {
    console.log("data, error", data, error);
    if (data) this.boats = data;
    else if (error) console.log("error", error);
  }

  @api searchBoats(boatTypeId) {
    this.isLoading = true;
    this.boatTypeId = boatTypeId;
    this.notifyLoading();
  }

  updateSelectedTile(event) {
    this.selectedBoatId = event.detail.boatId;
    this.sendMessageService(this.selectedBoatId);
  }

  sendMessageService(boatId) {
    // explicitly pass boatId to the parameter recordId
    const payload = { recordId: boatId };
    publish(this.messageContext, BOATMC, payload);
  }

  handleSave(event) {
    // notify loading
    const updatedFields = event.detail.draftValues;
    // Update the records via Apex
    updateBoatList({ data: updatedFields })
      .then(() => {
        const toast = new ShowToastEvent({
          title: SUCCESS_TITLE,
          message: MESSAGE_SHIP_IT,
          variant: SUCCESS_VARIANT,
        });
        this.dispatchEvent(toast);
        this.draftValues = [];
        return this.refresh();
      })
      .catch(error => {
        const toast = new ShowToastEvent({
          title: ERROR_TITLE,
          message: error.message,
          variant: ERROR_VARIANT,
        });
        this.dispatchEvent(toast);
      })
      .finally(() => {

      });
  }

  @api async refresh() {
    this.isLoading = true;
    this.notifyLoading(this.isLoading);
    await refreshApex(this.boats);
    this.isLoading = false;
    this.notifyLoading(this.isLoading);
  }

  notifyLoading(isLoading) {
    if (isLoading) this.dispatchEvent(new CustomEvent("loading"));
    else this.dispatchEvent(new CustomEvent("doneloading"));
  }
}

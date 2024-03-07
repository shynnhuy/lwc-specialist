import { LightningElement, api } from "lwc";
import getAllReviews from "@salesforce/apex/BoatDataService.getAllReviews";
import { NavigationMixin } from "lightning/navigation";

// imports
export default class BoatReviews extends NavigationMixin(LightningElement) {
  // Private
  boatId;
  error;
  boatReviews;
  isLoading;

  // Getter and Setter to allow for logic to run on recordId change
  get recordId() {
    return this.boatId;
  }
  @api set recordId(value) {
    console.log("value", value);
    //sets boatId attribute
    this.setAttribute("boatId", value);
    //sets boatId assignment
    this.boatId = value;
    //get reviews associated with boatId
    this.getReviews();
  }

  // Getter to determine if there are reviews to display
  get reviewsToShow() {
    return (
      this.boatReviews !== null &&
      this.boatReviews !== undefined &&
      this.boatReviews.length > 0
    );
  }

  // Public method to force a refresh of the reviews invoking getReviews
  @api refresh() {
    this.getReviews();
  }

  // Imperative Apex call to get reviews for given boat
  // returns immediately if boatId is empty or null
  // sets isLoading to true during the process and false when it’s completed
  // Gets all the boatReviews from the result, checking for errors.
  async getReviews() {
    if (!this.boatId) return;
    console.log("this.boatId", this.boatId);
    getAllReviews({ boatId: this.boatId })
      .then((result) => {
        console.log("result", result);
        this.boatReviews = result;
        this.error = null;
      })
      .catch((error) => {
        this.error = error;
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  // Helper method to use NavigationMixin to navigate to a given record on click
  navigateToRecord(event) {
    event.preventDefault();
    event.stopPropagation();
    let recordId = event.target.dataset.recordId;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: "User",
        actionName: "view"
      }
    });
  }
}

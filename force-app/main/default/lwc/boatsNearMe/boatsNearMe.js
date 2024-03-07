import getBoatsByLocation from "@salesforce/apex/BoatDataService.getBoatsByLocation";
import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const LABEL_YOU_ARE_HERE = "You are here!";
const ICON_STANDARD_USER = "standard:user";
const ERROR_TITLE = "Error loading Boats Near Me";
const ERROR_VARIANT = "error";

export default class BoatsNearMe extends LightningElement {
  @api boatTypeId;

  isRendered;
  isLoading = true;
  mapMarkers = [];
  latitude;
  longitude;

  @wire(getBoatsByLocation, {
    boatTypeId: "$boatTypeId",
    longitude: "$longitude",
    latitude: "$latitude"
  })
  wiredBoatsJSON({ data, error }) {
    if (data) {
      this.createMapMarkers(data);
    } else if (error) {
      console.log("error get boats by location: ", error);
      const toast = new ShowToastEvent({
        title: ERROR_TITLE,
        variant: ERROR_VARIANT,
        message: error.message
      });
      this.dispatchEvent(toast);
    }
    this.isLoading = false
  }

  getLocationFromBrowser() {
    if (navigator.geolocation)
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.longitude = position.coords.longitude;
          this.latitude = position.coords.latitude;
        },
        (err) => {
          console.warn(`ERROR(${err.code}): ${err.message}`);
        }
      );
  }

  renderedCallback() {
    if (!this.isRendered) this.getLocationFromBrowser();
    this.isRendered = true;
  }

  // Creates the map markers
  createMapMarkers(boatData) {
    const newMarkers = JSON.parse(boatData).map((boat) => ({
      title: boat.Name,
      location: {
        Latitude: boat.Geolocation__Latitude__s,
        Longitude: boat.Geolocation__Longitude__s
      }
    }));
    newMarkers.unshift({
      title: LABEL_YOU_ARE_HERE,
      icon: ICON_STANDARD_USER,
      location: {
        longitude: this.longitude,
        latitude: this.latitude
      }
    });

    this.mapMarkers = newMarkers;
  }
}

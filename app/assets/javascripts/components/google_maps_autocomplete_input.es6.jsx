class GoogleMapsAutocompleteInput extends React.Component {
  constructor(props) {
    super(props);

    this.$addressInput = $($(`#${this.props.addressInputId}`));
    this.$latitudeInput = $($(`#${this.props.latitudeInputId}`));
    this.$longitudeInput = $($(`#${this.props.longitudeInputId}`));

    if (this.props.defaultLocation && this.props.defaultLocation.lat) {
      this.defaultZoom = 15;
      this.defaultLocation = this.props.defaultLocation;
    } else {
      this.defaultZoom = 12;
      this.defaultLocation = { lat: 41.3833, lng: 2.1833 };
    }
  }

  componentDidMount() {
    $(document).on('gmaps:loaded', (event) => this.forceUpdate());
    this.createGmapsIntegration();
  }

  componentWillUnmount() {
    $(document).off('gmaps:loaded');
  }

  componentDidUpdate() {
    this.createGmapsIntegration();
  }

  createGmapsIntegration () {
    if (window.google) {
      this.createMap();
      this.createAutocomplete();
    }
  }
  
  createMap() {
    this.map = new google.maps.Map(
      $('.gmaps_autocomplete_input .map')[0], 
      {
        zoom: this.defaultZoom,
        center: this.defaultLocation,
        draggable: false,
        scrollwheel: false,
        mapTypeControl: false,
        panControl: false,
        zoomControl: false,
        streetViewControl: false
      }
    );

    this.service = new google.maps.places.PlacesService(this.map);

    this.marker = new google.maps.Marker({
      position: this.defaultLocation,
      animation: google.maps.Animation.DROP,
      map: this.map
    });
  }

  createAutocomplete() {
    this.$addressInput.on('keydown', (event) => {
      let key = event.keyCode;

      if (key === 13) { // Prevent form submission
        event.preventDefault();
      }
    });

    this.$addressInput.on('change', (event) => { this.onInputChanged(event.currentTarget.value) });

    this.autocomplete = new google.maps.places.Autocomplete(
      this.$addressInput[0],
      { 
        componentRestrictions: { 
          country: 'es' 
        }
      }
    );

    this.autocomplete.addListener('place_changed', () => { this.onPlaceChanged() });
  }

  onInputChanged(value) {
    this.searchTimeoutId = setTimeout(() => {
    this.service.textSearch({ 
      query: value,
      componentRestrictions: { 
        country: 'es' 
      }
    }, (results, status) => {
        if (status == google.maps.places.PlacesServiceStatus.OK && results.length > 0) {
          this.$addressInput.val(results[0].formatted_address);
          this.setPlace(results[0]);
        }
      });
    }, 200);
  }

  onPlaceChanged() {
    clearTimeout(this.searchTimeoutId);
    this.setPlace(this.autocomplete.getPlace());
  }

  setPlace(place) {
    if (place.geometry) {
      this.map.panTo(place.geometry.location);
      this.map.setZoom(15);
      this.marker.setPosition(place.geometry.location);
      this.$latitudeInput.val(place.geometry.location.lat());
      this.$longitudeInput.val(place.geometry.location.lng());
    }
  }

  render() {
    return (
      <div className="gmaps_autocomplete_input">
        <div className="map"></div>
      </div>
    )
  }
}

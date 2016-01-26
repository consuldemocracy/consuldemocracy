class MeetingsMap extends React.Component {
  constructor(props) {
    super(props);
    this.defaultZoom = 12;
    this.defaultLocation = { lat: 41.3833, lng: 2.1833 };
    this.currentInfoWindow = null;
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
      if (!this.map) {
        this.createMap();
      }
      this.createMarkers();
    }
  }

  createMap() {
    this.map = new google.maps.Map(
      $('.map')[0], 
      {
        zoom: this.defaultZoom,
        center: this.defaultLocation,
        scrollwheel: false,
        mapTypeControl: true,
        zoomControl: true,
        streetViewControl: true
      }
    );
  }

  createMarkers() {
    if (this.markerClusterer) {
      this.markerClusterer.clearMarkers();
    } else {
      this.markerClusterer = new MarkerClusterer(this.map, [], {
        gridSize: 30,
        ignoreHidden: true,
        enableRetinaIcons: true,
        maxZoom: 13,
        minimumClusterSize: 1
      });
    }

    let markers = this.props.meetings.map((meeting) => {
      let map = this.map,
          marker = new google.maps.Marker({
            position: {
              lat: meeting.address_latitude,
              lng: meeting.address_longitude,
            },
            icon: {
              path: "M25 0c-8.284 0-15 6.656-15 14.866 0 8.211 15 35.135 15 35.135s15-26.924 15-35.135c0-8.21-6.716-14.866-15-14.866zm-.049 19.312c-2.557 0-4.629-2.055-4.629-4.588 0-2.535 2.072-4.589 4.629-4.589 2.559 0 4.631 2.054 4.631 4.589 0 2.533-2.072 4.588-4.631 4.588z",
              fillOpacity: 1,
		          strokeColor: '#fff',
              strokeWeight: 2,
              size: {width: 27, height: 35},
              anchor: new google.maps.Point(20, 40),
              scale: 0.6,
              fillColor: '#fa494a',
            },
            map: map
          });

      marker._meeting = meeting;
      marker.addListener('click', () => {
        let infoWindow = new google.maps.InfoWindow({
            content: `<div class="meeting-infowindow">
                        <a href="/meetings/${meeting.id}" class="meeting-title">${meeting.title}</a>
                        <p class="tags"><span class="radius secondary label">${meeting.held_at}</span></p>
                        <div>${ meeting.description }</div>
                      </div>`
          });
        markers.map((marker) => { if(marker.infoWindow) marker.infoWindow.close(); } );
        marker.infoWindow = infoWindow;
        infoWindow.open(map, marker);
      });

      return marker;
    });

    this.markerClusterer.addMarkers(markers);
  }

  render () {
    return (
      <div className="map"></div>
    )
  }
}

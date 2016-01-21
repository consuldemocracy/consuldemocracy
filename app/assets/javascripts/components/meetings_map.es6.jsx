class MeetingsMap extends React.Component {
  constructor(props) {
    super(props);
    this.defaultZoom = 12;
    this.defaultLocation = { lat: 41.3833, lng: 2.1833 };
    this.currentInfoWindow = null;
  }

  componentDidMount() {
    $(document).on('gmaps:loaded', (event) => this.forceUpdate());
    $(document).on('meetings:filtered', (event, { meetings } ) => this.filterMeetings(meetings));
    this.createGmapsIntegration();
  }

  componentWillUnmount() {
    $(document).off('gmaps:loaded');
    $(document).on('meetings:filtered');
  }

  componentDidUpdate() {
    this.createGmapsIntegration();
  }

  createGmapsIntegration () {
    if (window.google) {
      this.createMap();
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

    google.maps.event.addListener(this.map, 'bounds_changed', () => {
      this.checkMarkersVisibility();
    });
  }

  createMarkers() {
    let markers = this.props.meetings.map((meeting) => {
      let map = this.map,
          marker = new google.maps.Marker({
            position: {
              lat: meeting.address_latitude,
              lng: meeting.address_longitude,
            },
            animation: google.maps.Animation.DROP,
            icon: {
              path: "M25 0c-8.284 0-15 6.656-15 14.866 0 8.211 15 35.135 15 35.135s15-26.924 15-35.135c0-8.21-6.716-14.866-15-14.866zm-.049 19.312c-2.557 0-4.629-2.055-4.629-4.588 0-2.535 2.072-4.589 4.629-4.589 2.559 0 4.631 2.054 4.631 4.589 0 2.533-2.072 4.588-4.631 4.588z",
              fillOpacity: 1,
		          strokeColor: '#fff',
              strokeWeight: 2,
              size: {width: 25, height: 25},
              scale: 0.6,
              fillColor: '#970092',
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

    this.markers = markers;
    this.markerClusterer = new MarkerClusterer(this.map, this.markers, {
      gridSize: 30,
      ignoreHidden: true
    });
  }

  checkMarkersVisibility () {
    let bounds = this.map.getBounds(),
        visibleMeetings = [];

    this.markers.forEach((marker) => {
      if (marker.visible && bounds.contains(marker.getPosition())) {
        visibleMeetings.push(marker._meeting);
      }
    });

    $(document).trigger('meetings:visible', { visibleMeetings });
  }

  centerMapOnMeeting (meeting, marker) {
    this.map.setCenter({
      lat: meeting.address_latitude,
      lng: meeting.address_longitude
    });
    this.map.setZoom(16);
    if (!marker) {
      marker = this.findMarkerByMeeting(meeting);
    }
  }

  openMarkerWindow (marker) {
    if (marker) {
      this.closeCurrentWindow();
      marker._infoWindow.open(this.map, marker);
      this.currentInfoWindow = marker._infoWindow;
    }
  }

  closeCurrentWindow () {
    if (this.currentInfoWindow) {
      this.currentInfoWindow.close();
    }
  }

  findMarkerByMeeting (meeting) {
    let markers = this.markers.filter((marker) => {
      return marker._meeting.id === meeting.id;
    });

    if (markers.length > 0) {
      return markers[0];
    }
  }

  filterMeetings(meetings) {
    meetingIds = meetings.map((meeting) => meeting.id);

    this.markers.forEach((marker) => {
      marker.setVisible(meetingIds.indexOf(marker._meeting.id) !== -1);
    });

    this.markerClusterer.repaint();

    $(document).trigger('meetings:visible', { visibleMeetings: meetings });
  }

  render () {
    return (
      <div className="map"></div>
    )
  }
}

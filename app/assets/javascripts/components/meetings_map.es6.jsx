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
        marker.infoWindow = infoWindow;
        markers.map((marker) => { if(marker.infoWindow) marker.infoWindow.close(); } );
        infoWindow.open(map, marker);
      });

      return marker;
    });

    this.markers = markers;
    this.markerClusterer = new MarkerClusterer(this.map, this.markers, { ignoreHidden: true });
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

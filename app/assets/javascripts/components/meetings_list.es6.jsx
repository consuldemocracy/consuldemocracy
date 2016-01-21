class MeetingsList extends React.Component {
  constructor(props) {
    super(props);

    this.meetings = [];

    this.state = {
      meetings: [],
      currentPage: 1,
      totalPages: 1,
      perPage: this.props.page,
    };
  }

  componentDidMount() {
    $(document).on('meetings:visible', (event, { visibleMeetings }) => {
      this.setState({ 
        meetings: visibleMeetings,
        currentPage: 1,
        totalPages: Math.ceil(visibleMeetings.length / this.props.perPage)
      });
    });
  }

  componentWillUnmount() {
    $(document).off('meetings:visible');
  }

  componentWillUpdate(nextProps, nextState) {
    let begin = (nextState.currentPage - 1) * this.props.perPage,
        end = begin + this.props.perPage;
    
    this.meetings = nextState.meetings.slice(begin, end);
  }

  render () {
    return (
      <div>
        <ul className="small-block-grid-2 medium-block-grid-3 large-block-grid-4">
          {
            this.meetings.map((meeting) => {
              return (
                <li className="meeting" key={ `meeting_${meeting.id}` } >
                  <a href={meeting.url} className="meeting-title" >
                    { meeting.title }
                  </a>
                  <div className="tags">
                    <span className="radius secondary label">{ meeting.held_at }</span>
                  </div>
                  <p>{ meeting.description }</p>
                  <p><i className="fa fa-map-o"></i> { meeting.address }</p>
                </li>
              )
            })
          }
        </ul>
        <div className="row">
          <Pagination 
            currentPage={this.state.currentPage}
            totalPages={this.state.totalPages}
            onSetCurrentPage={(page) => this.setCurrentPage(page)} />
        </div>
      </div>
    );
  }

  setCurrentPage(page) {
    this.setState({ currentPage: page });
  }
}

MeetingsList.defaultProps = { 
  perPage: 12
};

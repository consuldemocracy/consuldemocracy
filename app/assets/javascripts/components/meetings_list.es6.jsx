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
        <div className="row">
          <div className="list">
          {
            this.meetings.map((meeting) => {
              return (
                <a href={meeting.url} className="meeting large-3 small-6 columns end" key={ `meeting_${meeting.id}` }>
                  <p className="title">{ meeting.title }</p>
                  <p>{ meeting.description }</p>
                  <p>{ meeting.held_at }</p>
                  <p>{ meeting.address }</p>
                </a>
              )
            })
          }
          </div>
        </div>
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

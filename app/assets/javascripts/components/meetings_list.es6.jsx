class MeetingsList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      currentPage: 1
    };
  }

  render () {
    let begin = (this.state.currentPage - 1) * this.props.perPage,
        end = begin + this.props.perPage,
        meetings = this.props.meetings.slice(begin, end);

    return (
      <div>
        <ul className="small-block-grid-2 medium-block-grid-3 large-block-grid-4">
          {
            meetings.map((meeting) => {
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
            totalPages={Math.ceil(this.props.meetings.length / this.props.perPage)}
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

class MeetingsDirectory extends React.Component {
  render () {
    return (
      <div className="meetings-directory">
        <div className="small-12 medium-3 column">
          <aside className="sidebar" role="complementary">
            <MeetingsFilter districts={this.props.districts} meetings={this.props.meetings} />
          </aside>
        </div>

        <div id="proposals" className="small-12 medium-9 column">
          <MeetingsMap meetings={this.props.meetings} />
        </div>

        <MeetingsList />
      </div>
    );
  }
}

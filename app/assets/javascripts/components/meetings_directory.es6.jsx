class MeetingsDirectory extends React.Component {
  constructor(props) {
    super(props);
  }

  render () {
    return (
      <div className="meetings-directory">
        <MeetingsMap meetings={this.props.meetings} />
        <MeetingsFilter meetings={this.props.meetings} />
        <MeetingsList />
      </div>
    );
  }
}

class MeetingsDirectory extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      meetings: this.props.meetings
    };
  }

  render () {
    return (
      <div className="meetings-directory">
        <div className="small-12 medium-3 column">
          <aside className="sidebar" role="complementary">
            <MeetingsFilter 
              filter={this.props.filter}
              districts={this.props.districts} 
              meetings={this.state.meetings} 
              categories={this.props.categories}
              subcategories={this.props.subcategories} 
              onFilterResult={(meetings) => this.setState({ meetings })} />
          </aside>
        </div>

        <div id="proposals" className="small-12 medium-9 column">
          <div className="row">
            <MeetingsMap meetings={this.state.meetings} />
          </div>
          <div className="row">
            <MeetingsList meetings={this.state.meetings} />
          </div>
        </div>

      </div>
    );
  }
}

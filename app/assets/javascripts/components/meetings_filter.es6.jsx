class MeetingsFilter extends React.Component {
  render() {
    return (
      <form>
        <div className="row collapse prefix-radius">
          <div className="small-2 large-1 columns">
            <span className="prefix"><i className="icon-search"></i></span>
          </div>
          <div className="small-10 large-11 columns">
            <input 
              placeholder="Cercar" 
              onChange={(event) => this.filterByText(event.target.value)} 
              onKeyDown={(event) => this.onKeyDown(event)} />
          </div>
        </div>
      </form>
    )
  }

  filterByText(text) {
     let rex = new RegExp(text, "igm");
         filteredMeetings = this.props.meetings.filter((meeting) => {
           return meeting.title.match(rex) || meeting.description.match(rex);
         });

    $(document).trigger('meetings:filtered', { meetings: filteredMeetings });
  }

  onKeyDown(event) {
    let key = event.keyCode;

    if (key === 13) { // Prevent form submission
      event.preventDefault();
    }
  }
}

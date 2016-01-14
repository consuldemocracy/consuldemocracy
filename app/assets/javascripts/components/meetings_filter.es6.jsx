class MeetingsFilter extends React.Component {
  render() {
    return (
      <form>
        <div className="input-prepend">
          <span className="add-on"><i className="icon-search"></i></span>
          <input 
            placeholder="Cercar" 
            onChange={(event) => this.filterByText(event.target.value)} 
            onKeyDown={(event) => this.onKeyDown(event)} />
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

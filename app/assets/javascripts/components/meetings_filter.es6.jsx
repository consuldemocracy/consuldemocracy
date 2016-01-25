class MeetingsFilter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      /*search: this.props.filter.search_filter,*/
      //tags: Immutable.Set(this.props.filter.tag_filter || []),
      /*filters : Immutable.Map(this.props.filter.params || {})*/
      search: '',
      tags: Immutable.Set([]),
      filters : Immutable.Map({})
    };
  }

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
        <ScopeFilterOptionGroup 
          filterGroupValue={this.state.filters.get('scope')} 
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) } />
        <DistrictFilterOptionGroup 
          scopeSelected={this.state.filters.get('scope')}
          districts={this.props.districts} 
          filterGroupValue={this.state.filters.get('district')}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) } />
        <CategoryFilterOptionGroup
          categories={this.props.categories}
          filterGroupValue={this.state.filters.get('category_id')} 
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) } />
        <SubcategoryFilterOptionGroup
          selectedCategory={this.state.filters.get('category_id')}
          subcategories={this.props.subcategories}
          filterGroupValue={this.state.filters.get('subcategory_id')}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) } />
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

  changeFilterGroup(filterGroupName, filterGroupValue) {
    let filters = this.state.filters.set(filterGroupName, filterGroupValue);
    /*if (filterGroupName === 'category_id') {*/
      //filters = this.checkFilterSubcategoryIds(filters);
    /*}*/
    if (filterGroupName === 'scope' && filterGroupValue !== 'district') {
      filters = filters.delete('district');
    }
    //this.applyFilters(filters.toObject(), this.state.tags.toArray());
    this.setState({ filters });
  }

}

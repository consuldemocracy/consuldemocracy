class MeetingsFilter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      searchText: this.props.filter.search_filter,
      tags: Immutable.Set(this.props.filter.tag_filter || []),
      filters : Immutable.Map(this.props.filter.params || {})
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
        <TagCloudFilter 
          currentTags={this.state.tags} 
          tagCloud={this.props.filter.tag_cloud} 
          onSetFilterTags={(tags) => this.setFilterTags(tags)} />
      </form>
    )
  }

  onKeyDown(event) {
    let key = event.keyCode;

    if (key === 13) { // Prevent form submission
      event.preventDefault();
    }
  }

  filterByText(searchText) {
    if (this.searchTimeoutId) {
      clearTimeout(this.searchTimeoutId);
    }

    this.searchTimeoutId = setTimeout(() => {
      this.applyFilters(
        this.state.filters.toObject(), 
        this.state.tags.toArray(),
        searchText
      );
      this.setState({ searchText });
    }, 300);
  }

  changeFilterGroup(filterGroupName, filterGroupValue) {
    let filters = this.state.filters.set(filterGroupName, filterGroupValue);
    if (filterGroupName === 'category_id') {
      filters = filters.delete('subcategory_id')
    }
    if (filterGroupName === 'scope' && filterGroupValue !== 'district') {
      filters = filters.delete('district');
    }
    this.applyFilters(
      filters.toObject(), 
      this.state.tags.toArray(),
      this.state.searchText
    );
    this.setState({ filters });
  }

  setFilterTags(tags) {
    this.applyFilters(
      this.state.filters.toObject(), 
      tags.toArray(), 
      this.state.searchText
    );
    this.setState({ tags });
  }

  applyFilters(filters, tags, searchText) {
    let filterString = [], 
        data;

    for (let filterGroupName in filters) {
      if(filters[filterGroupName].length > 0) {
        filterString.push(`${filterGroupName}=${filters[filterGroupName].join(',')}`);
      }
    }

    filterString = filterString.join(':');

    data = {
      search: searchText,
      tag: tags,
      filter: filterString 
    }

    this.replaceUrl(data);

    $.ajax(this.props.filterUrl, { data, dataType: "json" }).then((result) => {
      this.props.onFilterResult(result);
    });
  }

  replaceUrl(data) {
    if (Modernizr.history) {
      let queryParams = [],
          url;

      if (data.searchText) {
        queryParams.push(`search=${data.searchText}`);
      }

      if (data.tag) {
        queryParams.push(`tag=${data.tag}`);
      }

      if (data.filter) {
        queryParams.push(`filter=${data.filter}`);
      }

      url = `${location.href.replace(/\?.*/, "")}?${queryParams.join('&')}`;

      history.replaceState(data, '', url);
    }
  }

}

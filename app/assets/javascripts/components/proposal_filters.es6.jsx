class ProposalFilters extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      search: this.props.filter.search_filter,
      tags: Immutable.Set(this.props.filter.tag_filter || []),
      filters : Immutable.Map(this.props.filter.params || {})
    };
  }

  render() {
    return (
      <form>
        <FilterOptionGroup 
          filterGroupName="source" 
          filterGroupValue={this.state.filters.get('source')}
          isExclusive={true}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
          <FilterOption filterName="official" />
          <FilterOption filterName="citizenship" />
        </FilterOptionGroup>
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
    );
  }

  changeFilterGroup(filterGroupName, filterGroupValue) {
    let filters = this.state.filters.set(filterGroupName, filterGroupValue);
    if (filterGroupName === 'category_id') {
      filters = filters.delete('subcategory_id')
    }
    if (filterGroupName === 'scope' && filterGroupValue !== 'district') {
      filters = filters.delete('district');
    }
    this.applyFilters(filters.toObject(), this.state.tags.toArray());
    this.setState({ filters });
  }

  setFilterTags(tags) {
    this.applyFilters(this.state.filters.toObject(), tags.toArray());
    this.setState({ tags });
  }

  applyFilters(filters, tags) {
    let filterString = [], 
        data;

    for (let filterGroupName in filters) {
      if(filters[filterGroupName].length > 0) {
        filterString.push(`${filterGroupName}=${filters[filterGroupName].join(',')}`);
      }
    }

    filterString = filterString.join(':');

    data = {
      search: this.state.search,
      tag: tags,
      filter: filterString 
    }

    $('#proposals').html('Loading...');
    this.replaceUrl(data);
    $.ajax(this.props.filterUrl, { data, dataType: "script" });
  }

  replaceUrl(data) {
    if (Modernizr.history) {
      let queryParams = [],
          url;

      if (this.state.search) {
        queryParams.push(`search=${this.state.search}`);
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

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
        <ProposalFilterOptionGroup 
          filterGroupName="source" 
          filterGroupValue={this.state.filters.get('source')}
          isExclusive={true}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
          <ProposalFilterOption filterName="oficial" />
          <ProposalFilterOption filterName="citizenship" />
        </ProposalFilterOptionGroup>
        <ProposalFilterOptionGroup 
          filterGroupName="scope" 
          filterGroupValue={this.state.filters.get('scope')}
          isExclusive={true}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
          <ProposalFilterOption filterName="city" />
          <ProposalFilterOption filterName="district" />
        </ProposalFilterOptionGroup>
        {(() => {
          if(this.state.filters.get('scope') && this.state.filters.get('scope').indexOf("district") !== -1) {
            return (
              <ProposalFilterOptionGroup 
                filterGroupName="district" 
                filterGroupValue={this.state.filters.get('district')}
                onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
                {
                  this.props.districts.map(function (district) {
                    return <ProposalFilterOption key={district[1]} filterName={district[1]} filterLabel={district[0]} />
                  })
                }
              </ProposalFilterOptionGroup>
            )
          }
        })()}
        <ProposalFilterOptionGroup 
          filterGroupName="category_id" 
          filterGroupValue={this.state.filters.get('category_id')}
          isExclusive={true}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
          {
            this.props.categories.map(function (category) {
              return <ProposalFilterOption key={category.id} filterName={category.id} filterLabel={category.name}>
                <a href={`/categories#category_${category.id}`} target="_blank"><i className="fa fa-info-circle"></i></a>
              </ProposalFilterOption>
            })
          }
        </ProposalFilterOptionGroup>
        {(() => {
          if(this.state.filters.get('category_id') && this.state.filters.get('category_id').length > 0) {
            return (
              <ProposalFilterOptionGroup 
                filterGroupName="subcategory_id" 
                filterGroupValue={this.state.filters.get('subcategory_id')}
                onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.changeFilterGroup(filterGroupName, filterGroupValue) }>
                {
                  this.filteredSubCategories(this.state.filters).map(function (subcategory) {
                    return <ProposalFilterOption key={subcategory.id} filterName={subcategory.id} filterLabel={subcategory.name}>
                      <a href={`/categories#subcategory_${subcategory.id}`} target="_blank"><i className="fa fa-info-circle"></i></a>
                    </ProposalFilterOption>
                  })
                }
              </ProposalFilterOptionGroup>
            )
          }
        }())}
        <ProposalFilterTagCloud 
          currentTags={this.state.tags} 
          tagCloud={this.props.filter.tag_cloud} 
          onSetFilterTags={(tags) => this.setFilterTags(tags)} />
      </form>
    );
  }

  filteredSubCategories(filters) {
    return this.props.subcategories.filter((subcategory) => this.checkCategoryFiltered(filters, subcategory));
  }

  checkCategoryFiltered(filters, subcategory) {
    return filters.get('category_id') && filters.get('category_id').indexOf(subcategory.categoryId) !== -1;
  }

  changeFilterGroup(filterGroupName, filterGroupValue) {
    let filters = this.state.filters.set(filterGroupName, filterGroupValue);
    if (filterGroupName === 'category_id') {
      filters = this.checkFilterSubcategoryIds(filters);
    }
    if (filterGroupName === 'scope' && filterGroupValue !== 'district') {
      filters = filters.delete('district');
    }
    this.applyFilters(filters.toObject(), this.state.tags.toArray());
    this.setState({ filters });
  }

  checkFilterSubcategoryIds(filters) {
    let filterCategoryIds = filters.get('category_id'),
        filterSubCategoryIds = filters.get('subcategory_id'),
        allowedSubcategories = this.filteredSubCategories(filters).map((subcategory) => subcategory.id);

    if (filterSubCategoryIds) {
      filterSubCategoryIds = filterSubCategoryIds.filter((subcategory_id) => allowedSubcategories.indexOf(subcategory_id) !== -1);
      return filters.set('subcategory_id', filterSubCategoryIds);
    }

    return filters;
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

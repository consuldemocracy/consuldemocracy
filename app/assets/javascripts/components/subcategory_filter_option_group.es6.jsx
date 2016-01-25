class SubcategoryFilterOptionGroup extends React.Component {
  render() {
    if (this.props.selectedCategory && this.props.selectedCategory.length > 0) {
      let subcategories = this.props.subcategories.filter((subcategory) => this.props.selectedCategory.indexOf(subcategory.categoryId) !== -1);

      return (
        <FilterOptionGroup 
          filterGroupName="subcategory_id" 
          filterGroupValue={this.props.filterGroupValue}
          onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.props.onChangeFilterGroup(filterGroupName, filterGroupValue) }>
          {
            subcategories.map(function (subcategory) {
              return <FilterOption key={subcategory.id} filterName={subcategory.id} filterLabel={subcategory.name}>
                <a href={`/categories#subcategory_${subcategory.id}`} target="_blank"><i className="fa fa-info-circle"></i></a>
              </FilterOption>
            })
          }
        </FilterOptionGroup>
      )
    }
    return null;
  }
}
//subcategories={this.filteredSubCategories(this.state.filters)}

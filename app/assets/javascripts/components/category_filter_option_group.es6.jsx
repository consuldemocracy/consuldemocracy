class CategoryFilterOptionGroup extends React.Component {
  render() {
    return (
      <FilterOptionGroup 
        filterGroupName="category_id" 
        filterGroupValue={this.props.filterGroupValue}
        isExclusive={true}
        onChangeFilterGroup={(filterGroupName, filterGroupValue) => this.props.onChangeFilterGroup(filterGroupName, filterGroupValue) }>
        {
          this.props.categories.map(function (category) {
            return <FilterOption key={category.id} filterName={category.id} filterLabel={category.name}>
              <a href={`/categories#category_${category.id}`} target="_blank"><i className="fa fa-info-circle"></i></a>
            </FilterOption>
          })
        }
      </FilterOptionGroup>
    )
  }
}

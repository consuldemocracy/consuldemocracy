class ProposalCategoryPicker extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      selectedCategoryId: props.selectedCategoryId,
      selectedSubcategoryId: props.selectedSubcategoryId
    }
  }

  render () {
    return (
      <div>
        <CategoryPicker
            categories={this.props.categories}
            selectedId={this.state.selectedCategoryId}
            onSelect={ (category) => this.selectCategory(category) }
        />

        {this.actionLinePicker()}

        <input type="hidden"
               name={this.props.categoryInputName}
               value={this.state.selectedCategoryId} />

        <input type="hidden"
               name={this.props.subcategoryInputName}
               value={this.state.selectedSubcategoryId} />
      </div>
    );
  }

  actionLinePicker() {
    if(this.state.selectedCategoryId){
      return (
        <SubcategoryPicker
            categoryId={this.state.selectedCategoryId}
            subcategories={this.props.subcategories}
            selectedId={this.state.selectedSubcategoryId}
            onSelect={ (actionLine) => this.setState({selectedSubcategoryId: actionLine.id}) }
        />
      );
    }
  }

  selectCategory(category) {
    var state = {selectedCategoryId: category.id};

    if(this.state.selectedCategoryId !== category.id){
      state = {...state, selectedSubcategoryId: null };
    }

    this.setState(state);
  }
}

class CategoryPicker extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      selectedCategoryId: props.selectedCategoryId,
      selectedSubcategoryId: props.selectedSubcategoryId,
      subcategories: props.subcategories.sort( () => Math.round(Math.random())-0.5 )
    }
  }

  render () {
    var category = this.props.categories.map(category => this.renderRow(category));

    return (
      <div>
        <div className="category-picker">
          <label>{I18n.t("components.category_picker.category.label")}</label>
          <ul>{category}</ul>
        </div>

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

  renderRow (category) {
    var selected = this.state.selectedCategoryId === category.id;
    var name = category.name;

    var classNames = ['category-' + category.id];
    if(selected){ classNames.push('selected'); }

    return (
      <li className={classNames.join(' ')}
          key={category.id}
          onClick={() => this.selectCategory(category)}>
        <span className="category">{name}</span>
      </li>
    );
  }

  actionLinePicker() {
    if(this.state.selectedCategoryId){
      return (
        <SubcategoryPicker
            categoryId={this.state.selectedCategoryId}
            subcategories={this.state.subcategories}
            selectedId={this.state.selectedSubcategoryId}
            onSelect={ (actionLine) => this.setState({selectedSubcategoryId: actionLine.id}) }
        />
      );
    }
  }

  selectCategory(category){
    var state = {selectedCategoryId: category.id};

    if(this.state.selectedCategoryId !== category.id){
      state = {...state, selectedSubcategoryId: null };
    }

    this.setState(state);
  }
}

class ProposalFilterTagCloud extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tagCloud: this.props.tagCloud, 
      tags: Immutable.Set(this.props.currentTags)
    }
  }

  componentDidMount() {
    $(document).on('tags:reload', (event, tagCloud) => this.reloadTagCloud(event, tagCloud));
  }

  componentWillUnmount() {
    $(document).off('tags:reload');
  }

  reloadTagCloud(event, tagCloud) {
    this.setState({ tagCloud: JSON.parse(tagCloud) });
  }

  render() {
    return (
      <div id="tag-cloud" className="tag-cloud">
        {(() => {
          if(this.state.tagCloud.length > 0) {
            return (
              <div>
                <div className="sidebar-divider"></div>
                <h3>{I18n.t("shared.tags_cloud.tags")}</h3>
                <br></br>
              </div>
            )
          }
        }())}
        {
          this.state.tagCloud.map((tag) => {
          return <a 
              className={this.state.tags.has(tag.name) ? 'active' : ''}
              key={tag.id} 
              onClick={(event) => this.toggleTag(tag.name)}>
              {tag.name}&nbsp;
              <span className="label round info">{tag.count}</span>
            </a>
          })
        }
      </div>
    );
  }

  toggleTag(tag) {
    if (this.state.tags.has(tag)) {
      this.state.tags = this.state.tags.delete(tag);
    } else {
      this.state.tags = this.state.tags.add(tag);
    }

    this.props.onSetFilterTags(this.state.tags);
  }
}

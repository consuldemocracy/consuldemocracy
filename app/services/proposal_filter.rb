class ProposalFilter
  attr_reader :collection, :tag_cloud, :search_filter, :tag_filter, :params

  def initialize(params={})
    @search_filter = params[:search] if params[:search].present?
    @tag_filter = params[:tag]
    @params = params[:filter]
    @collection = Proposal.all
    filter_by_search
    filter_by_tag
    filter
    @tag_cloud = @collection.tag_counts.order("proposals_count": :desc, name: :asc).limit(20)
  end

  private

  def filter_by_search
    if @search_filter.present?
      @collection = @collection.search(@search_filter)
    end
  end

  def filter_by_tag
    if @tag_filter.present?
      if @tag_filter.kind_of? String
        @tag_filter = @tag_filter.split(',')
      end
      @tag_filter = @tag_filter if ActsAsTaggableOn::Tag.named_any(@tag_filter).exists?
      @collection = @collection.tagged_with(@tag_filter) if @tag_filter
    end
  end

  def filter
    if @params.present?
      @params = @params.split(':').reduce({}) do |result, filterGroup|
        filterGroupName, filterGroupValue = filterGroup.split('=')
        result[filterGroupName] = filterGroupValue.split(',') if filterGroupValue
        result
      end

      @params.each do |attr, value|
        @collection = @collection.where(attr => value)
      end
    end
  end
end

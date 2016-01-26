class ResourceFilter
  IGNORE_FILTER_PARAMS = ["source"]
  attr_reader :collection, :tag_cloud, :search_filter, :tag_filter, :params

  def initialize(resources, params={})
    @collection = resources
    @params = params[:filter]
    @exclude_ids = params[:exclude_ids]
    @search_filter = params[:search] if params[:search].present?
    @tag_filter = params[:tag]
    exclude
    parse_filter_params
    filter_by_search
    filter_by_tag
    filter
    @tag_cloud = @collection.tag_counts.order("#{resources.table_name}_count": :desc, name: :asc).limit(20)
  end

  private

  def exclude
    if @exclude_ids.present?
      @collection = @collection.where("id not in (?)", @exclude_ids)
    end
  end

  def parse_filter_params
    if @params.present?
      @params = @params.split(':').reduce({}) do |result, filterGroup|
        filterGroupName, filterGroupValue = filterGroup.split('=')
        result[filterGroupName] = filterGroupValue.split(',') if filterGroupValue
        result
      end

      if @params["source"].present?
        @params["official"] = @params["source"].include? "official"
      end
    end
  end

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
      @params.each do |attr, value|
        unless IGNORE_FILTER_PARAMS.include? attr
          @collection = @collection.where(attr => value)
        end
      end
    end
  end
end

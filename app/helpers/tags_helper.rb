module TagsHelper

  def taggable_path(taggable_type, tag_name)
    case taggable_type
    when 'debate'
      debates_path(tag: tag_name)
    when 'medida'
      medidas_path(tag: tag_name)
    when 'proposal'
      proposals_path(tag: tag_name)
    else
      '#'
    end
  end

  def taggable_counter_field(taggable_type)
    "#{taggable_type.underscore.pluralize}_count"
  end

  def tag_cloud(tags, classes, counter_field = :taggings_count)
    return [] if tags.empty?

    max_count = tags.sort_by(&counter_field).last.send(counter_field).to_f

    tags.each do |tag|
      index = ((tag.send(counter_field) / max_count) * (classes.size - 1))
      yield tag, classes[index.nan? ? 0 : index.round]
    end
  end
end

module TagsHelper
  def taggables_path(taggable, tag_name)
    case taggable.class.name
    when "Legislation::Proposal"
      legislation_process_proposals_path(taggable.process, search: tag_name)
    else
      polymorphic_path(taggable.class, search: tag_name)
    end
  end
end

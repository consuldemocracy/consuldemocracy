class Moderation::Shared::TableComponent < ApplicationComponent
  attr_reader :records, :ids_field_name
  use_helpers :wysiwyg

  def initialize(records, ids_field_name: "ids[]")
    @records = records
    @ids_field_name = ids_field_name
  end

  private

    def model_human_name
      records.model.model_name.human
    end

    def description_for(record)
      if record.respond_to?(:description)
        wysiwyg(record.description)
      else
        record.body
      end
    end

    def flaggable?
      records.first.respond_to?(:flags)
    end

    def title_and_link_for(record)
      if record.is_a?(Comment)
        commentable = record.commentable

        safe_join([commentable.model_name.human, link_to(commentable.title, polymorphic_path(commentable))],
                  " - ")
      elsif record.is_a?(ProposalNotification)
        link_to record.title, proposal_path(record.proposal, anchor: "tab-notifications")
      else
        link_to record.title, polymorphic_path(record)
      end
    end

    def check_box_attributes(record)
      { id: "#{dom_id(record)}_check" }.merge(check_box_aria_attributes(record))
    end

    def check_box_aria_attributes(record)
      { "aria-label": record.human_name }
    end
end

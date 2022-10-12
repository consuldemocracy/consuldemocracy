class AUE::FilterLinksComponent < ApplicationComponent
  attr_reader :records, :related_model, :see_more_link
  delegate :link_list, to: :helpers

  def initialize(records, related_model, see_more_link: nil)
    @records = records
    @related_model = related_model
    @see_more_link = see_more_link
  end

  def links
    [*aue_links, see_more_link]
  end

  private

    def aue_links
      records.map do |goal|
        [
          render(AUE::TagComponent.new(goal)),
          index_by(parameter_name => goal.code),
          title: filter_text(goal),
          data: { code: goal.code }
        ]
      end
    end

    def filter_text(goal)
      t("aue.goals.filter.link",
        resources: related_model.model_name.human(count: :other),
        code: goal.code)
    end

    def index_by(advanced_search)
      if related_model.name == "Legislation::Proposal"
        legislation_process_proposals_path(params[:id], advanced_search: advanced_search, filter: params[:filter])
      else
        polymorphic_path(related_model, advanced_search: advanced_search)
      end
    end

    def parameter_name
      "aue_goal"
    end
end

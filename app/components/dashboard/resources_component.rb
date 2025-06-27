class Dashboard::ResourcesComponent < ApplicationComponent
  attr_reader :active_resources, :proposal

  def initialize(active_resources, proposal)
    @active_resources = active_resources
    @proposal = proposal
  end

  private

    def default_resources
      %w[polls mailing poster]
    end
end

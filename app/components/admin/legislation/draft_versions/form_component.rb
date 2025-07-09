class Admin::Legislation::DraftVersions::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :draft_version, :url
  use_helpers :admin_submit_action

  def initialize(draft_version, url:)
    @draft_version = draft_version
    @url = url
  end

  private

    def process
      draft_version.process
    end
end

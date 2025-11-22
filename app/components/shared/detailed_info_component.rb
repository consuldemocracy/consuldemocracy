class Shared::DetailedInfoComponent < ApplicationComponent
  attr_reader :record, :comments_path, :preview
  alias_method :preview?, :preview
  use_helpers :can?

  def initialize(record, comments_path: "#comments", preview: false)
    @record = record
    @comments_path = comments_path
    @preview = preview
  end
end

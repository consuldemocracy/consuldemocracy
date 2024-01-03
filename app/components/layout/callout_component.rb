class Layout::CalloutComponent < ApplicationComponent
  attr_reader :id, :type, :message
  delegate :sanitize, to: :helpers

  def initialize(id:, type: "success", message:)
    @id = id
    @type = type
    @message = message
  end
end

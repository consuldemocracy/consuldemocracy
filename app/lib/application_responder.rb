class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  def api_behavior
    raise MissingRenderer.new(format) unless has_renderer?

    if get? || post?
      super
    else
      display resource, status: :ok
    end
  end
end

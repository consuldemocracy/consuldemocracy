# TODO: remove once we upgrade Foundation
SassC::Engine.class_eval do
  alias_method :original_initialize, :initialize

  def initialize(template, options = {})
    original_initialize(template, options.merge(quiet_deps: true))
  end
end

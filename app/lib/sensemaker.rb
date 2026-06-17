module Sensemaker
  def self.enabled?
    ::Llm::Config.configured? && Setting["llm.use_sensemaker"].present?
  end
end

module Sensemaker
  def self.enabled?
    Setting["llm.use_sensemaker"].present? && ::Llm::Config.sensemaker_model_available?
  end
end

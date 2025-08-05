RubyLLM.configure do |config|
  return if Rails.application.secrets.llm.blank?

  # set up all possible providers
  Rails.application.secrets.llm.each do |key, value|
    config.send("#{key}=", value)
  end
end

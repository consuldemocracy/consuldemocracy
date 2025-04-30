module Secrets
  def stub_secrets(configuration)
    allow(Rails.application).to receive(:secrets).and_return(
      ActiveSupport::OrderedOptions.new.merge(configuration)
    )
  end
end

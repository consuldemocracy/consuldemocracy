class Admin::Stats::StatComponent < ApplicationComponent
  attr_reader :text, :amount, :options

  def initialize(text:, amount:, options: {})
    @text = text
    @amount = amount
    @options = options
  end
end

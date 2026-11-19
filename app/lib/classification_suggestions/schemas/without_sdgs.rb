require "ruby_llm/schema"

module ClassificationSuggestions
  module Schemas
    class WithoutSdgs < RubyLLM::Schema
      array :categories, of: :string, max_items: 2
      array :tags, of: :string
    end
  end
end

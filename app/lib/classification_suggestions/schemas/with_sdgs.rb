require "ruby_llm/schema"

module ClassificationSuggestions
  module Schemas
    class WithSdgs < RubyLLM::Schema
      array :categories, of: :string, max_items: 2
      array :tags, of: :string
      array :sdgs do
        object do
          string :code
          string :reason
        end
      end
    end
  end
end

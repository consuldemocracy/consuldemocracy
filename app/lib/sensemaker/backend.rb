# frozen_string_literal: true

module Sensemaker
  module Backend
    def self.for(job, runtime_config:)
      Node.new(job, runtime_config: runtime_config)
    end
  end
end

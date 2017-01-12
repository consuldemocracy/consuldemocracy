module PublicForApi

  extend ActiveSupport::Concern

  class_methods do
    def public_for_api
      all
    end
  end
end

ActiveRecord::Base.send(:include, PublicForApi)

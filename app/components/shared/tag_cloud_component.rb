class Shared::TagCloudComponent < ApplicationComponent
  attr_reader :taggable_class_name

  def initialize(taggable_class_name)
    @taggable_class_name = taggable_class_name
  end

  private

    def tag_cloud
      TagCloud.new(taggable_class, params[:search])
    end

    def taggable_class
      taggable_class_name.constantize
    end
end

class Shared::TagCloudComponent < ApplicationComponent
  attr_reader :tag_cloud, :taggable

  def initialize(tag_cloud, taggable:)
    @tag_cloud = tag_cloud
    @taggable = taggable
  end
end

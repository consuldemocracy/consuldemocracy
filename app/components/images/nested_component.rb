class Images::NestedComponent < ApplicationComponent
  attr_reader :f, :image_fields
  delegate :imageable_humanized_accepted_content_types, :imageable_max_file_size, to: :helpers

  def initialize(f, image_fields: :image)
    @f = f
    @image_fields = image_fields
  end

  private

    def imageable
      f.object
    end

    def note
      t "images.form.note", accepted_content_types: imageable_humanized_accepted_content_types,
        max_file_size: imageable_max_file_size
    end
end

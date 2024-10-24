class Admin::Settings::ImagesAndDocumentsTabComponent < ApplicationComponent
  def tab
    "#tab-images-and-documents"
  end

  def images_settings
    %w[
      uploads.images.title.min_length
      uploads.images.title.max_length
      uploads.images.min_width
      uploads.images.min_height
      uploads.images.max_size
    ]
  end

  def documents_settings
    %w[
      uploads.documents.max_amount
      uploads.documents.max_size
    ]
  end
end

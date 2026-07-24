class DirectUploads::FieldsComponent < ApplicationComponent
  attr_reader :direct_upload

  def initialize(direct_upload)
    @direct_upload = direct_upload
  end

  private

    def fields_content
      form_for resource, url: false do |form|
        case attachable.class.name
        when "Document"
          return document_fields(form)
        when "Image"
          return image_fields(form)
        end
      end
    end

    def document_fields(form)
      form.fields_for :documents, attachable, child_index: nested_index do |documents_builder|
        render Documents::FieldsComponent.new(documents_builder)
      end
    end

    def image_fields(form)
      form.fields_for image_fields_name, attachable, child_index: nested_index do |image_builder|
        render Images::FieldsComponent.new(image_builder, imageable: resource)
      end
    end

    def nested_index
      SecureRandom.random_number(10**12)
    end

    def image_fields_name
      if resource.class.reflect_on_association(:image)
        :image
      else
        :images
      end
    end

    def resource
      direct_upload.resource
    end

    def attachable
      direct_upload.relation
    end
end

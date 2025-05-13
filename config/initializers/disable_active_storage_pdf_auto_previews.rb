ActiveSupport.on_load(:active_storage_attachment) do
  # Code copied from Rails 7.2. TODO: remove after upgrading to Rails 7.2
  # See: https://github.com/rails/rails/pull/51351/files
  class ActiveStorage::Attachment
    private
      def transform_variants_later
        preprocessed_variations = named_variants.filter_map { |_name, named_variant|
          if named_variant.preprocessed?(record)
            named_variant.transformations
          end
        }

        if blob.preview_image_needed_before_processing_variants? && preprocessed_variations.any?
          blob.create_preview_image_later(preprocessed_variations)
        else
          preprocessed_variations.each do |transformations|
            blob.preprocessed(transformations)
          end
        end
      end
  end
end

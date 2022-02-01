# frozen_string_literal: true

# Code copied from the ckeditor gem:
# https://github.com/galetahub/ckeditor/pull/853
module Ckeditor
  module Backend
    module ActiveStorage
      def self.included(base)
        base.send(:include, Rails.application.routes.url_helpers)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
      end

      module ClassMethods
        def self.extended(base)
          base.class_eval do
            before_save :apply_data
            validate do
              if data.nil? || storage_file.nil?
                errors.add(:data, :not_data_present, message: "data must be present")
              end
            end
          end
        end
      end

      module InstanceMethods
        def url
          rails_blob_path(self.storage_data, only_path: true)
        end

        def path
          rails_blob_path(self.storage_data, only_path: true)
        end

        def styles
        end

        def content_type
          self.storage_data.content_type
        end

        def content_type=(_content_type)
          self.storage_data.content_type = _content_type
        end

        protected

          def storage_file
            @storage_file ||= storage_data
          end

          def blob
            @blob ||= ::ActiveStorage::Blob.find(storage_file.attachment.blob_id)
          end

          def apply_data
            non_paperclip_data = if data.is_a?(::Paperclip::Attachment)
                                   file.instance_variable_get("@target")
                                 else
                                   data
                                 end

            if non_paperclip_data.is_a?(Ckeditor::Http::QqFile)
              storage_data.attach(io: non_paperclip_data, filename: non_paperclip_data.original_filename)
            else
              storage_data.attach(non_paperclip_data)
            end

            self.data_file_name = storage_data.blob.filename
            self.data_content_type = storage_data.blob.content_type
            self.data_file_size = storage_data.blob.byte_size
          end
      end
    end

    autoload :ActiveStorage, "ckeditor/backend/active_storage"
  end
end

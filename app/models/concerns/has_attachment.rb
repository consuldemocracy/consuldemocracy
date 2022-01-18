module HasAttachment
  extend ActiveSupport::Concern

  class_methods do
    def has_attachment(attribute, paperclip_options = {})
      has_one_attached :"storage_#{attribute}"

      has_attached_file attribute, paperclip_options
      alias_method :"paperclip_#{attribute}=", :"#{attribute}="

      define_method :"#{attribute}=" do |file|
        if file.is_a?(IO) || file.is_a?(Tempfile) && !file.is_a?(Ckeditor::Http::QqFile)
          send(:"storage_#{attribute}").attach(io: file, filename: File.basename(file.path))
        elsif file.nil?
          send(:"storage_#{attribute}").detach
        else
          send(:"storage_#{attribute}").attach(file)
        end

        send(:"paperclip_#{attribute}=", file)
      end
    end
  end
end

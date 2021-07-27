module HasAttachment
  extend ActiveSupport::Concern

  class_methods do
    def has_attachment(attribute, paperclip_options = {})
      has_one_attached :"storage_#{attribute}"

      define_method :"storage_#{attribute}=" do |file|
        if file.is_a?(IO)
          send(:"storage_#{attribute}").attach(io: file, filename: File.basename(file.path))
        elsif file.nil?
          send(:"storage_#{attribute}").detach
        else
          send(:"storage_#{attribute}").attach(file)
        end
      end

      has_attached_file attribute, paperclip_options
      alias_method :"paperclip_#{attribute}=", :"#{attribute}="

      define_method :"#{attribute}=" do |file|
        send(:"storage_#{attribute}=", file)
        send(:"paperclip_#{attribute}=", file)
      end
    end
  end
end

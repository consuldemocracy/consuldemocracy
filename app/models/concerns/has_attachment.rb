module HasAttachment
  extend ActiveSupport::Concern

  class_methods do
    def has_attachment(attribute)
      has_one_attached attribute

      define_method :"#{attribute}=" do |file|
        if file.is_a?(IO)
          send(attribute).attach(io: file, filename: File.basename(file.path))
        elsif file.nil?
          send(attribute).detach
        else
          send(attribute).attach(file)
        end
      end
    end
  end
end

class ApplicationDecorator < Draper::Decorator
  def self.translate(*attributes)
    attributes.each do |attribute| 
      define_method attribute do
        object.send(attribute)[I18n.locale.to_s]
      end
    end
  end
end

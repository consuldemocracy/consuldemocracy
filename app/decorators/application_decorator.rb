class ApplicationDecorator < Draper::Decorator
  def self.translates(*attributes)
    attributes.each do |attribute| 
      define_method attribute do
        translation = object.send(attribute)
        translation ? translation[I18n.locale.to_s] : nil
      end
    end
  end
end

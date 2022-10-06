class Layout::CommonHTMLAttributesComponent < ApplicationComponent
  delegate :rtl?, to: :helpers

  private

    def attributes
      sanitize([dir, lang].compact.join(" "))
    end

    def dir
      'dir="rtl"' if rtl?
    end

    def lang
      "lang=\"#{I18n.locale}\""
    end
end

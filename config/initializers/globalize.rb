module Globalize
  module ActiveRecord
    module InstanceMethods
      def save(*)
        # Credit for this code belongs to Jack Tomaszewski:
        # https://github.com/globalize/globalize/pull/578
        Globalize.with_locale(Globalize.locale || I18n.default_locale) do
          super
        end
      end
    end
  end
end

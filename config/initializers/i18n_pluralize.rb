### From official I18n::Backend::Base
### https://github.com/svenfuchs/i18n/blob/f35b839693c5ecc7ea0ff0f57c5cbf6db1dd73f9/lib/i18n/backend/base.rb#L155
### Just changed one line to return `count` instead of raising the exception `InvalidPluralizationData`

module I18n
  module Backend
    module Base

      def pluralize(locale, entry, count)
        return entry unless entry.is_a?(Hash) && count

        key = pluralization_key(entry, count)
        return count unless entry.has_key?(key)
        entry[key]
      end

    end
  end
end
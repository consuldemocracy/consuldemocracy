Kaminari.configure do |config|
  # config.default_per_page = 25
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end


# Overrides for making Kaminari handle i18n pluralization correctly
#
# Remove everything below once https://github.com/amatsuda/kaminari/pull/694 is
# merged in Kaminari and we have updated
module Kaminari

  module ActionViewExtension
    def page_entries_info(collection, options = {})
      entry_name = if options[:entry_name]
                     options[:entry_name].pluralize(collection.size)
                   else
                     collection.entry_name(:count => collection.size).downcase
                   end

      if collection.total_pages < 2
        t('helpers.page_entries_info.one_page.display_entries', entry_name: entry_name, count: collection.total_count)
      else
        first = collection.offset_value + 1
        last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
        t('helpers.page_entries_info.more_pages.display_entries', entry_name: entry_name, first: first, last: last, total: collection.total_count)
      end.html_safe
    end
  end

  module ActiveRecordRelationMethods
    def entry_name(options = {})
      model_name.human(options.reverse_merge(default: model_name.human.pluralize(options[:count])))
    end
  end

  module MongoidCriteriaMethods
    def entry_name(options = {})
      model_name.human(options.reverse_merge(default: model_name.human.pluralize(options[:count])))
    end
  end

  class PaginatableArray < Array
    ENTRY = 'entry'.freeze

    def entry_name(options = {})
      I18n.t('helpers.page_entries_info.entry', options.reverse_merge(default: ENTRY.pluralize(options[:count])))
    end
  end

end

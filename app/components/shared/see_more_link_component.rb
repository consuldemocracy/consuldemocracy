class Shared::SeeMoreLinkComponent < ApplicationComponent
  attr_reader :record, :association_name, :limit

  def initialize(record, association_name, i18n_namespace: nil, limit: nil)
    @record = record
    @association_name = association_name
    @i18n_namespace = i18n_namespace
    @limit = limit
  end

  def i18n_namespace
    @i18n_namespace ||= association_name.to_s.tr("_", ".")
  end

  private

    def text
      "#{count_out_of_limit}+"
    end

    def url
      polymorphic_path(record)
    end

    def title
      t("#{i18n_namespace}.filter.more", count: count_out_of_limit)
    end

    def count_out_of_limit
      return 0 unless limit

      record.send(association_name).size - limit
    end

    def html_class
      "more-#{i18n_namespace.split(".").last}"
    end
end

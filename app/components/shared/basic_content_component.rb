class Shared::BasicContentComponent < ApplicationComponent
  attr_reader :record, :show_tags
  alias_method :show_tags?, :show_tags
  use_helpers :locale_and_user_status, :namespace, :namespaced_polymorphic_path, :wysiwyg

  def initialize(record, show_tags: true)
    @record = record
    @show_tags = show_tags
  end

  private

    def path
      if namespace == "management"
        management_polymorphic_path(record)
      else
        polymorphic_path(record)
      end
    end

    def summary
      if record.respond_to?(:summary)
        tag.p(record.summary)
      else
        wysiwyg(record.description)
      end
    end
end

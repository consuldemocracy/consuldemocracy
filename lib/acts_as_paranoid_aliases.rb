module ActsAsParanoidAliases

  def self.included(base)
    base.extend(ClassMethods)

    def hide
      update_attribute(:hidden_at, Time.now)
      after_hide
    end

    def hidden?
      deleted?
    end

    def after_hide
    end
  end

  module ClassMethods
    def with_hidden
      with_deleted
    end

    def only_hidden
      only_deleted
    end

    def hide_all(ids)
      return if ids.blank?
      where(id: ids).update_all(hidden_at: Time.now)
    end

    def restore_all(ids)
      return if ids.blank?
      only_hidden.where(id: ids).update_all(hidden_at: nil)
    end
  end

end

module ActsAsParanoid
  include ActsAsParanoidAliases
end
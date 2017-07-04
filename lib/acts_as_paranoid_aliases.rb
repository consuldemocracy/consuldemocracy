module ActsAsParanoidAliases

  def self.included(base)
    base.extend(ClassMethods)
    class_eval do

      def hide
        return false if hidden?
        update_attribute(:hidden_at, Time.current)
        after_hide
      end

      def hidden?
        deleted?
      end

      def after_hide
      end

      def confirmed_hide?
        confirmed_hide_at.present?
      end

      def confirm_hide
        update_attribute(:confirmed_hide_at, Time.current)
      end

      def restore(opts = {})
        return false unless hidden?
        super(opts)
        update_attribute(:confirmed_hide_at, nil)
        after_restore
      end

      def after_restore
      end
    end
  end

  module ClassMethods
    def with_confirmed_hide
      where.not(confirmed_hide_at: nil)
    end

    def without_confirmed_hide
      where(confirmed_hide_at: nil)
    end

    def with_hidden
      with_deleted
    end

    def only_hidden
      only_deleted
    end

    def hide_all(ids)
      return if ids.blank?
      where(id: ids).each(&:hide)
    end

    def restore_all(ids)
      return if ids.blank?
      only_hidden.where(id: ids).each(&:restore)
    end
  end
end

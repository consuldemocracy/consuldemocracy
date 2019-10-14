class Budget
  class Ballot
    class  Confirmation < ActiveRecord::Base

      belongs_to :ballot
      belongs_to :group
      belongs_to :budget
      belongs_to :user, class_name: 'User' #Ballot Owner

      acts_as_paranoid column: :discarted_at

      attr_accessor :provided_sms_confirmation_code

      belongs_to :confirmed_by_user, class_name: 'User' # User who perform the action
      belongs_to :discarted_by_user, class_name: 'User' # User who perform the action
      belongs_to :created_by_user, class_name: 'User' # User who perform the action
      belongs_to :sms_code_sent_by_user, class_name: 'User' # User who perform the action

      validates :ballot_summary, presence: true
      validates :ballot, presence: true
      validates :group, presence: true

      validates :sms_code_sent_by_username, presence: true, if: :confirmation_code_sent?
      validates :sms_code_sent_by_user_id, presence: true, if: :confirmation_code_sent?

      validates :confirmed_by_username, presence: true, if: :confirmed?
      validates :confirmed_by_user_id, presence: true, if: :confirmed?

      validate :only_one_confirmed_ballot_at_same_time

      scope :confirmed, -> { where(discarted_at: nil) }
      scope :online, -> { where.not(confirmed_at: nil).where.not(sms_code_sent_at: nil) }
      scope :by_manager, -> { where.not(confirmed_at: nil).where(sms_code_sent_at: nil) }

      def self.build_ballot_confirmation(ballot, current_user, user_performing = nil)

        Budget::Ballot::Confirmation.create!(ballot: ballot,
                                                    budget: ballot.budget, group: ballot.group,
                                                    created_by_user: current_user,
                                                    created_by_username: user_performing || current_user.email,
                                                    user: current_user, phone_number: current_user.confirmed_phone,
                                                    ballot_summary: ballot.summary)
      end

      def resend_confirmation_code(current_user, user_performing = nil)
        update!(sms_confirmation_code: nil)
        send_confirmation_code(current_user, user_performing)
      end

      def send_confirmation_code(current_user, user_performing = nil)
        if  phone_number && sms_confirmation_code.nil?

          update!(sms_confirmation_code: generate_confirmation_code,
                 sms_code_sent_by_user: current_user,
                 sms_code_sent_by_username: user_performing || current_user.email
          )

          # Protect for SMS credit out. Rollback will be notified but process will be finished
          begin
            deliver_sms_confirmation_code()
            update!(sms_code_sent_at: Time.now)
          rescue Exception => error
            Rollbar.error(error)
            update(sms_code_sending_error: error.inspect)
          end
          true

        else

          false
        end
      end

      def commit(code, current_user, user_performing = nil)
        if sms_confirmation_code.eql?(code)
          update(confirmed_at: Time.now,
                 confirmed_by_user: current_user,
                 confirmed_by_username: user_performing || current_user.email
          )
        end
      end

      def masked_phone_number(masked_digits=4, include_mask=nil)
        if phone_number && phone_number.size > masked_digits
          offset = phone_number.size - masked_digits
          prefix = include_mask ? Array.new(offset, '*').join : ''
          suffix = phone_number[offset, phone_number.size]

          "#{prefix}#{suffix}"
        end

      end
      
      def discard(current_user, user_performing = nil)
        update!(discarted_by_user: current_user, discarted_by_username: user_performing || current_user.email, discarted_at: Time.now)
      end

      # Predicates

      def confirmed?
        !confirmed_at.nil?
      end

      def confirmed_with_code?
        confirmed? && !code.nil?
      end

      def confirmed_without_code?
        confirmed? && code.nil?
      end

      def confirmation_code_sent?
        !confirmation_code_unsent?
      end

      def confirmation_code_unsent?
        sms_code_sent_at.nil?
      end

      private

      def generate_confirmation_code
        rand.to_s[2..5]
      end

      def deliver_sms_confirmation_code
        if phone_number && sms_confirmation_code
          SMSApiCustom.new.ballot_confirm_sms_deliver(phone_number, I18n.t('budgets.ballot_confirmation_sms_body', code: sms_confirmation_code))
        end
      end

      def only_one_confirmed_ballot_at_same_time
        return if discarted_at
        if Budget::Ballot::Confirmation.where(ballot_id: ballot_id, discarted_at: nil).where.not(id: id).any?
          errors.add(:ballot, :already_confirmed)
        end
      end
    end
  end
end

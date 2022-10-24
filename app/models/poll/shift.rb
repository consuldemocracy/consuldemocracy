class Poll
  class Shift < ApplicationRecord
    belongs_to :booth
    belongs_to :officer

    validates :booth_id, presence: true
    validates :officer_id, presence: true
    validates :date, presence: true, uniqueness: { scope: [:officer_id, :booth_id, :task] }
    validates :task, presence: true

    enum task: { vote_collection: 0, recount_scrutiny: 1 }

    scope :current, -> { where(date: Date.current) }

    before_create :persist_data
    after_create :create_officer_assignments
    before_destroy :destroy_officer_assignments

    def title
      "#{I18n.t("admin.poll_shifts.#{task}")} #{officer_name} #{I18n.l(date.to_date, format: :long)}"
    end

    def persist_data
      self.officer_name = officer.name
      self.officer_email = officer.email
    end

    def create_officer_assignments
      booth.booth_assignments.order(:id).each do |booth_assignment|
        attrs = {
          officer_id:          officer_id,
          date:                date,
          booth_assignment_id: booth_assignment.id,
          final:               recount_scrutiny?
        }
        Poll::OfficerAssignment.create!(attrs)
      end
    end

    def unable_to_destroy?
      booth.booth_assignments.map(&:unable_to_destroy?).any?
    end

    def destroy_officer_assignments
      Poll::OfficerAssignment.where(booth_assignment: booth.booth_assignments,
                                    officer: officer,
                                    date: date,
                                    final: recount_scrutiny?).destroy_all
    end
  end
end

# == Schema Information
#
# Table name: poll_shifts
#
#  id            :integer          not null, primary key
#  booth_id      :integer
#  officer_id    :integer
#  date          :date
#  created_at    :datetime
#  updated_at    :datetime
#  officer_name  :string
#  officer_email :string
#  task          :integer          default(0), not null
#

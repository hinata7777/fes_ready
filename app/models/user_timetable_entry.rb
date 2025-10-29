class UserTimetableEntry < ApplicationRecord
  belongs_to :user
  belongs_to :stage_performance

  validates :stage_performance_id, uniqueness: { scope: :user_id }
end

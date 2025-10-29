class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # 将来 SNS ログイン
  # devise :omniauthable, omniauth_providers: [:google_oauth2]

  enum :role, { general: 0, admin: 1 }
  validates :nickname, presence: true, length: { maximum: 10 }

  has_many :user_timetable_entries, dependent: :destroy
  has_many :my_stage_performances, through: :user_timetable_entries, source: :stage_performance

  def picked?(stage_performance)
    user_timetable_entries.exists?(stage_performance_id: stage_performance.id)
  end
end

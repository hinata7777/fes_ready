class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # 将来 SNS ログイン
  # devise :omniauthable, omniauth_providers: [:google_oauth2]
  
  enum :role, { general: 0, admin: 1 }

  validates :nickname, presence: true, length: { maximum: 10 }
end

class UserFestivalFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :festival

  validates :user_id, uniqueness: { scope: :festival_id }
end

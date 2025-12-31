module Favoritable
  extend ActiveSupport::Concern

  included do
    # Modelごとに「お気に入り中間テーブル」の関連名を設定する
    class_attribute :favoritable_join_association, instance_writer: false

    scope :favorited_by, ->(user) {
      joins(favoritable_join_association)
        .where(favoritable_join_association => { user_id: user.id })
    }
  end

  class_methods do
    def favoritable_by(association_name)
      self.favoritable_join_association = association_name
    end
  end

  def favorited_by?(user)
    return false unless user

    public_send(favoritable_join_association).exists?(user_id: user.id)
  end
end

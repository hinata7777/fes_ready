class PackingList < ApplicationRecord
  include TemplateOwned

  include Uuidable

  belongs_to :user, optional: true
  belongs_to :festival_day, optional: true

  has_many :packing_list_items, dependent: :destroy, inverse_of: :packing_list
  has_many :items, through: :packing_list_items

  accepts_nested_attributes_for :packing_list_items, allow_destroy: true

  validates :title, presence: true, length: { maximum: 100 }
  validates :title, uniqueness: { scope: :user_id, message: "は既に存在します" }, unless: :template?
  validate :festival_day_must_be_upcoming_if_changed

  def past_selected_festival_day(today = Date.current)
    return unless festival_day
    festival_day if festival_day.finished?(today)
  end

  # テンプレート複製時、フォーム初期化時にテンプレート内容をこのリストに適用する
  def apply_template_from_id(template_id)
    return if template_id.blank?

    template = PackingList.templates.find_by(id: template_id)
    return unless template

    self.title = template.title
    template.packing_list_items.includes(:item).order(:position, :id).each do |pli|
      packing_list_items.build(
        item_id: pli.item_id,
        position: pli.position,
        note: pli.note
      )
    end
  end

  # リストアイテム作成時、同名のアイテムがテンプレートにあれば再利用し、なければユーザー所有の新規アイテムとして紐付ける
  def assign_owner_to_new_items!(user)
    packing_list_items.each do |pli|
      pli.packing_list ||= self
      next unless pli.item&.new_record?

      item_name = pli.item.name.to_s.strip
      if item_name.present?
        existing_item = user.items.find_by(name: item_name) || Item.templates.find_by(name: item_name)
        if existing_item
          pli.item = existing_item
          next
        end
      end

      pli.item.user = user
      pli.item.template = false
    end
  end

  private

  def festival_day_must_be_upcoming_if_changed
    return unless will_save_change_to_festival_day_id?
    return if festival_day.blank?
    errors.add(:festival_day, "は開催前の日程を選んでください") if festival_day.finished?
  end
end

module PackingListsHelper
  def packing_list_item_name(packing_list_item)
    packing_list_item.item&.name.presence || "未設定の持ち物"
  end

  def packing_list_item_new_record?(packing_list_item)
    packing_list_item.item&.new_record?
  end
end

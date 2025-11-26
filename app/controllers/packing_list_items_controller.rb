class PackingListItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_packing_list
  before_action :set_packing_list_item, only: [ :update, :destroy, :toggle ]

  def create
    @packing_list_item = @packing_list.packing_list_items.build(packing_list_item_params)
    if @packing_list_item.save
      redirect_to @packing_list, notice: "持ち物を追加しました"
    else
      redirect_to @packing_list, alert: "追加に失敗しました"
    end
  end

  def update
    if @packing_list_item.update(packing_list_item_params)
      redirect_to @packing_list, notice: "持ち物を更新しました"
    else
      redirect_to @packing_list, alert: "更新に失敗しました"
    end
  end

  def destroy
    @packing_list_item.destroy!
    redirect_to @packing_list, notice: "持ち物を削除しました"
  end

  def toggle
    @packing_list_item.update!(checked: !@packing_list_item.checked)
    redirect_to @packing_list, notice: "チェックを更新しました"
  end

  private

  def set_packing_list
    @packing_list = current_user.packing_lists.find(params[:packing_list_id])
  end

  def set_packing_list_item
    @packing_list_item = @packing_list.packing_list_items.find(params[:id])
  end

  def packing_list_item_params
    params.require(:packing_list_item).permit(:item_id, :note, :position)
  end
end

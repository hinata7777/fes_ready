class PackingListItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_packing_list
  before_action :set_packing_list_item

  def update
    # チェックの付け外し専用: Turbo Streamで行だけ更新する。
    if @packing_list_item.update(packing_list_item_params)
      respond_to do |format|
        # Turbo対応: 行だけ差し替え
        format.turbo_stream
        # Turbo非対応時のフォールバック
        format.html { redirect_to @packing_list, notice: "持ち物を更新しました" }
      end
    else
      respond_to do |format|
        # Turbo対応: エラー時も行だけ差し替え
        format.turbo_stream { render turbo_stream: turbo_stream.replace("packing_list_item_#{@packing_list_item.id}", partial: "packing_lists/item", locals: { packing_list: @packing_list, pli: @packing_list_item, owned_list: true }) }
        # Turbo非対応時のフォールバック
        format.html { redirect_to @packing_list, alert: "更新に失敗しました" }
      end
    end
  end

  private

  def set_packing_list
    @packing_list = current_user.packing_lists.find_by!(uuid: params[:packing_list_id])
  end

  def set_packing_list_item
    @packing_list_item = @packing_list.packing_list_items.find(params[:id])
  end

  def packing_list_item_params
    params.require(:packing_list_item).permit(:checked)
  end
end

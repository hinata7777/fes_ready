class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: :destroy

  def index
    @items = Item.templates.or(Item.owned_by(current_user)).order(:name)
  end

  def new
    @item = current_user.items.build
  end

  def create
    @item = current_user.items.build(item_params)
    if @item.save
      redirect_to items_path, notice: "持ち物を追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    redirect_to items_path, notice: "持ち物を削除しました"
  end

  private

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :category)
  end
end

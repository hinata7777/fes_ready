class Admin::ItemsController < Admin::BaseController
  before_action :set_item, only: [ :edit, :update, :destroy ]

  def index
    @pagy, @items = pagy(Item.templates.order(:name), limit: 30)
  end

  def new
    @item = Item.new(template: true)
  end

  def create
    @item = Item.new(item_params.merge(template: true, user: nil))
    if @item.save
      redirect_to admin_items_path, notice: "持ち物を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @item.update(item_params.merge(template: true, user: nil))
      redirect_to admin_items_path, notice: "持ち物を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    redirect_to admin_items_path, notice: "持ち物を削除しました"
  end

  private

  def set_item
    @item = Item.templates.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :category)
  end
end

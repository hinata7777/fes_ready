class PackingListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_packing_list, only: [ :show, :edit, :update, :destroy, :duplicate_from_template ]
  before_action :set_owned_packing_list, only: [ :edit, :update, :destroy ]

  def index
    @template_lists = PackingList.templates.order(:title)
    @packing_lists = current_user.packing_lists.order(created_at: :desc)
  end

  def show
    @packing_list_items = @packing_list.packing_list_items.includes(:item).order(:position, :id)
  end

  def new
    @packing_list = current_user.packing_lists.build
    @template_lists = PackingList.templates.order(:title)
  end

  def create
    @packing_list = current_user.packing_lists.build(packing_list_params)
    if @packing_list.save
      redirect_to @packing_list, notice: "持ち物リストを作成しました"
    else
      @template_lists = PackingList.templates.order(:title)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @template_lists = PackingList.templates.order(:title)
  end

  def update
    if @packing_list.update(packing_list_params)
      redirect_to @packing_list, notice: "持ち物リストを更新しました"
    else
      @template_lists = PackingList.templates.order(:title)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @packing_list.destroy!
    redirect_to packing_lists_path, notice: "持ち物リストを削除しました"
  end

  def duplicate_from_template
    unless @packing_list.template?
      redirect_to packing_lists_path, alert: "テンプレートのみ複製できます" and return
    end

    new_list = current_user.packing_lists.build(title: @packing_list.title)
    ActiveRecord::Base.transaction do
      new_list.save!
      @packing_list.packing_list_items.find_each do |pli|
        new_list.packing_list_items.create!(
          item_id: pli.item_id,
          position: pli.position,
          note: pli.note
        )
      end
    end

    redirect_to new_list, notice: "テンプレートからリストを作成しました"
  rescue ActiveRecord::RecordInvalid
    redirect_to packing_lists_path, alert: "複製に失敗しました"
  end

  private

  def set_packing_list
    @packing_list = PackingList.templates.or(PackingList.owned_by(current_user)).find(params[:id])
  end

  def set_owned_packing_list
    @packing_list = current_user.packing_lists.find(params[:id])
  end

  def packing_list_params
    params.require(:packing_list).permit(:title)
  end
end

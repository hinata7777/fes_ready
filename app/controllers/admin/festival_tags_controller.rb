class Admin::FestivalTagsController < Admin::BaseController
  before_action :set_festival_tag, only: %i[edit update destroy]

  def index
    @festival_tags = FestivalTag.order(:name)
    @festival_tag = FestivalTag.new
  end

  def create
    @festival_tag = FestivalTag.new(festival_tag_params)
    if @festival_tag.save
      redirect_to admin_festival_tags_path, notice: "タグを作成しました。"
    else
      @festival_tags = FestivalTag.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @festival_tag.update(festival_tag_params)
      redirect_to admin_festival_tags_path, notice: "タグを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @festival_tag.destroy!
    redirect_to admin_festival_tags_path, notice: "タグを削除しました。"
  end

  private

  def set_festival_tag
    @festival_tag = FestivalTag.find(params[:id])
  end

  def festival_tag_params
    params.require(:festival_tag).permit(:name)
  end
end

class Admin::SetlistsController < Admin::BaseController
  before_action :set_setlist, only: %i[edit update show destroy]
  before_action :prepare_options, only: %i[new edit create update]
  before_action :set_artists, only: %i[index]

  def index
    scope = Setlist.includes(stage_performance: :artist).order(created_at: :desc)
    scope = scope.joins(:stage_performance).where(stage_performances: { artist_id: params[:artist_id] }) if params[:artist_id].present?
    @pagy, @setlists = pagy(scope, limit: 20)
  end

  def show; end

  def new
    @setlist = Setlist.new
    Admin::Setlists::FormBuilder.build(@setlist)
  end

  def create
    @setlist = Setlist.new(setlist_params)
    if @setlist.save
      redirect_to admin_setlists_path, notice: "セットリストを作成しました"
    else
      Admin::Setlists::FormBuilder.build(@setlist)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    Admin::Setlists::FormBuilder.build(@setlist)
  end

  def update
    if @setlist.update(setlist_params)
      redirect_to admin_setlists_path, notice: "セットリストを更新しました"
    else
      Admin::Setlists::FormBuilder.build(@setlist)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @setlist.destroy!
    redirect_to admin_setlists_path, notice: "セットリストを削除しました"
  end

  private

  def set_setlist
    @setlist = Setlist.includes(stage_performance: :artist, setlist_songs: :song)
                      .find_by!(uuid: params[:id])
  end

  def setlist_params
    permitted = params.require(:setlist).permit(
      :stage_performance_id,
      setlist_songs_attributes: %i[id song_id position note _destroy]
    )

    # 曲未選択の行は _destroy=1 にして無視する
    if permitted[:setlist_songs_attributes].present?
      permitted[:setlist_songs_attributes].each_value do |attrs|
        attrs[:_destroy] = "1" if attrs[:song_id].blank?
      end
    end

    permitted
  end

  def prepare_options
    @artists = Artist.order(:name)
    @stage_performances_by_artist = StagePerformance.includes(:festival_day, :stage)
                                                    .order(:starts_at)
                                                    .group_by(&:artist_id)
    # 曲のプルダウンは全曲だと大きくなるので、選択したアーティストの曲だけをJSで絞る運用を想定
    # ここでは全曲を渡す
    @songs_by_artist = Song.includes(:artist).order(:name).group_by(&:artist_id)
  end

  def set_artists
    @artists = Artist.order(:name)
  end
end

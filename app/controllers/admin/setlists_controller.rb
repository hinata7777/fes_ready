class Admin::SetlistsController < Admin::BaseController
  before_action :set_setlist, only: %i[edit update destroy]
  before_action :prepare_options, only: %i[new edit create update]
  before_action :set_artists, only: %i[index]

  def index
    scope = Setlist.includes(
      stage_performance: [ :artist, :stage, { festival_day: :festival } ],
      setlist_songs: []
    ).order(created_at: :desc)
    scope = scope.joins(:stage_performance).where(stage_performances: { artist_id: params[:artist_id] }) if params[:artist_id].present?
    @pagy, @setlists = pagy(scope, limit: 20)
  end

  def new
    form = Admin::Setlists::Form.new(setlist: Setlist.new)
    form.build_rows
    @setlist = form.setlist
  end

  def create
    form = Admin::Setlists::Form.new(setlist: Setlist.new, params: params)
    @setlist = form.setlist
    if form.save
      redirect_to admin_setlists_path, notice: "セットリストを作成しました"
    else
      form.build_rows
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    form = Admin::Setlists::Form.new(setlist: @setlist)
    form.build_rows
  end

  def update
    form = Admin::Setlists::Form.new(setlist: @setlist, params: params)
    if form.save
      redirect_to admin_setlists_path, notice: "セットリストを更新しました"
    else
      form.build_rows
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @setlist.destroy!
    redirect_to admin_setlists_path, notice: "セットリストを削除しました"
  end

  private

  def set_setlist
    @setlist = Setlist.includes(stage_performance: [ :festival_day, :stage ], setlist_songs: :song)
                      .find_by!(uuid: params[:id])
  end

  def prepare_options
    @artists = Artist.order(:name)
    @stage_performances_by_artist = StagePerformance.includes(:stage, festival_day: :festival)
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

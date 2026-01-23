class Admin::SetlistsController < Admin::BaseController
  before_action :set_setlist, only: %i[edit update destroy]
  before_action :prepare_options, only: %i[new edit create update]
  before_action :set_artists, only: %i[index]

  def index
    scope = Setlist.includes(
      :setlist_songs,
      stage_performance: [ :artist, :stage, { festival_day: :festival } ]
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
    artist_id = selected_artist_id
    if artist_id.present?
      @stage_performances_by_artist = StagePerformance.includes(:stage, festival_day: :festival)
                                                      .where(artist_id: artist_id)
                                                      .order(:starts_at)
                                                      .group_by(&:artist_id)
      @songs_by_artist = Song.includes(:artist)
                             .where(artist_id: artist_id)
                             .order(:name)
                             .group_by(&:artist_id)
    else
      @stage_performances_by_artist = {}
      @songs_by_artist = {}
    end
  end

  def set_artists
    @artists = Artist.order(:name)
  end

  def selected_artist_id
    return @setlist.stage_performance&.artist_id if @setlist&.stage_performance

    stage_performance_id = params.dig(:setlist, :stage_performance_id)
    return if stage_performance_id.blank?

    StagePerformance.where(id: stage_performance_id).pluck(:artist_id).first
  end
end

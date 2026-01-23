class Admin::SongsController < Admin::BaseController
  before_action :set_song, only: [ :edit, :update, :destroy ]
  before_action :set_artists, only: [ :index, :new, :edit, :create, :update ]

  def index
    # セットリストフォームのオンデマンド取得用にJSONが必要なため、HTMLと同じ一覧アクションで分岐して返す
    scope = Song.includes(:artist).order(:name)
    scope = scope.where(artist_id: params[:artist_id]) if params[:artist_id].present?
    respond_to do |format|
      format.html { @pagy, @songs = pagy(scope, limit: 20) }
      format.json do
        render_songs_json(scope)
      end
    end
  end

  def new
    @bulk_form = Admin::Songs::BulkForm.new({})
    @bulk_entries = Admin::Songs::BulkForm.empty_entries
  end

  def create
    form = Admin::Songs::BulkForm.new(bulk_params)

    if form.save
      redirect_to admin_songs_path, notice: "#{form.created_count}件の曲を追加しました。"
    else
      @bulk_form = form
      @bulk_entries = form.bulk_entries
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @song.update(song_params)
      redirect_to admin_songs_path, notice: "曲を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @song.destroy!
    redirect_to admin_songs_path, notice: "曲を削除しました"
  end

  private

  def set_song
    @song = Song.find(params[:id])
  end

  def set_artists
    @artists = Artist.order(:name)
  end

  def song_params
    params.require(:song).permit(:name, :spotify_id, :artist_id)
  end

  def bulk_params
    params.require(:bulk).permit(entries: %i[name spotify_id artist_id _destroy])
  end

  def render_songs_json(scope)
    if params[:all].blank? && params[:artist_id].blank?
      render json: { songs: [] }
      return
    end

    rows = scope.joins(:artist).pluck("songs.id", "songs.name", "artists.name")
    songs = rows.map { |id, name, artist_name| { id: id, name: name, artist_name: artist_name } }
    render json: { songs: songs }
  end
end

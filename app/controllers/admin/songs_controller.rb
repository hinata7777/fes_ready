class Admin::SongsController < Admin::BaseController
  before_action :set_song, only: [ :edit, :update, :destroy ]
  before_action :set_artists, only: [ :index, :new, :edit, :create, :update ]

  def index
    scope = Song.includes(:artist).order(:name)
    scope = scope.where(artist_id: params[:artist_id]) if params[:artist_id].present?
    @pagy, @songs = pagy(scope, limit: 20)
  end

  def new
    @bulk_entries = Admin::Songs::BulkCreator.empty_entries
  end

  def create
    result = Admin::Songs::BulkCreator.call(bulk_params)

    if result.success?
      redirect_to admin_songs_path, notice: "#{result.created_count}件の曲を追加しました。"
    else
      @bulk_entries = result.bulk_entries
      flash.now[:alert] = result.error_message
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
end

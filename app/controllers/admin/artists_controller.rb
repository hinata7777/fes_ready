class Admin::ArtistsController < Admin::BaseController
  before_action :set_artist, only: [ :edit, :update, :destroy ]

  def index
    @pagy, @artists = pagy(Artist.order(:name), limit: 20)
  end

  def new
    @artist = Artist.new
  end

  def create
    @artist = Artist.new(artist_params)
    if @artist.save
      redirect_to admin_artists_path, notice: "アーティストを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @artist.update(artist_params)
      redirect_to admin_artists_path, notice: "アーティストを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @artist.destroy!
    redirect_to admin_artists_path, notice: "アーティストを削除しました"
  end

  private
  def set_artist
    @artist = Artist.find_by_identifier!(params[:id])
  end

  def artist_params
    params.require(:artist).permit(:name, :spotify_artist_id, :image_url).tap do |p|
      p[:spotify_artist_id] = p[:spotify_artist_id].presence
    end
  end
end

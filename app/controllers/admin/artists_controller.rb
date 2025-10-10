class Admin::ArtistsController < Admin::BaseController
  before_action :set_artist, only: [ :edit, :update, :destroy ]

  def index
    @artists = Artist.order(updated_at: :desc)
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
    @artist = Artist.find(params[:id])
  end

  def artist_params
    params.require(:artist).permit(:name, :spotify_artist_id, :image_url)
  end
end

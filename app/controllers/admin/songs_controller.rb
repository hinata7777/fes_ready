class Admin::SongsController < Admin::BaseController
  before_action :set_song, only: [ :edit, :update, :destroy ]
  before_action :set_artists, only: [ :index, :new, :edit, :create, :update, :bulk_new, :bulk_create ]

  def index
    scope = Song.includes(:artist).order(:name)
    scope = scope.where(artist_id: params[:artist_id]) if params[:artist_id].present?
    @pagy, @songs = pagy(scope, limit: 20)
  end

  def new
    @song = Song.new
  end

  def create
    @song = Song.new(song_params)
    if @song.save
      redirect_to admin_songs_path, notice: "曲を登録しました"
    else
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

  def bulk_new
    @bulk_entries = build_bulk_entries([])
  end

  def bulk_create
    permitted = bulk_params
    entry_attrs = (permitted[:entries] || []).map do |attrs|
      next if ActiveModel::Type::Boolean.new.cast(attrs[:_destroy])
      {
        name: attrs[:name].to_s.strip,
        spotify_id: attrs[:spotify_id].presence,
        artist_id: attrs[:artist_id].presence
      }
    end.compact

    usable_entries = entry_attrs.select { |attrs| attrs[:name].present? && attrs[:artist_id].present? }

    if usable_entries.empty?
      flash.now[:alert] = "1行以上入力してください。"
      @bulk_entries = build_bulk_entries(entry_attrs)
      render :bulk_new, status: :unprocessable_entity and return
    end

    Song.transaction do
      usable_entries.each do |attrs|
        Song.create!(attrs)
      end
    end

    redirect_to admin_songs_path, notice: "#{usable_entries.size}件の曲を追加しました。"
  rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
    flash.now[:alert] = e.record&.errors&.full_messages&.first || "保存に失敗しました。"
    @bulk_entries = build_bulk_entries(entry_attrs)
    render :bulk_new, status: :unprocessable_entity
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

  def build_bulk_entries(entries)
    filled = entries.presence || []
    padding = [ 10 - filled.size, 0 ].max
    filled + Array.new(padding) { { name: nil, spotify_id: nil, artist_id: nil } }
  end
end

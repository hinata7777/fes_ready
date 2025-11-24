module NavigationHelper
  def header_back_path
    return nil if current_page?(root_path)
    return @header_back_path if defined?(@header_back_path) && @header_back_path.present?

    case controller_path
    when "home"
      home_back_path
    when "festivals", "festivals/artists"
      festivals_back_path
    when "artists", "artists/festivals"
      artists_back_path
    when "my_timetables"
      my_timetables_back_path
    when "mypages"
      root_path
    when "mypage/favorite_festivals", "mypage/favorite_artists"
      mypage_back_path
    else
      root_path
    end
  end

  private

  def home_back_path
    return safe_referer_path || root_path if %w[terms privacy].include?(action_name)

    root_path
  end

  def safe_referer_path
    return if request.referer.blank?

    uri = URI.parse(request.referer)
    return if uri.host.present? && uri.host != request.host

    path = uri.path.presence || root_path
    query = uri.query.present? ? "?#{uri.query}" : ""
    fragment = uri.fragment.present? ? "##{uri.fragment}" : ""
    "#{path}#{query}#{fragment}"
  rescue URI::InvalidURIError
    nil
  end

  def festivals_back_path
    case params[:from]
    when "artist_festivals"
      return artist_festivals_path(params[:artist_id]) if params[:artist_id].present?
    when "timetables"
      return timetables_path
    when "mypage_favorites"
      return mypage_favorite_festivals_path
    end

    return artist_path(params[:artist_id]) if params[:artist_id].present?

    case action_name
    when "index" then root_path
    when "timetable" then festival_path(params[:id])
    else
      festivals_path
    end
  end

  def artists_back_path
    case params[:from]
    when "festival_timetable"
      return timetable_back_path if params[:festival_id].present?
    when "my_timetable"
      return my_timetable_back_path
    when "mypage_favorites"
      return mypage_favorite_artists_path
    end

    return festival_path(params[:festival_id]) if params[:festival_id].present?

    case action_name
    when "index" then root_path
    else
      artists_path
    end
  end

  def timetable_back_path
    options = {}
    options[:date] = params[:date] if params[:date].present?
    timetable_path(params[:festival_id], options)
  end

  def my_timetable_back_path
    return root_path if params[:festival_id].blank?
    options = {}
    options[:date] = params[:date] if params[:date].present?
    options[:user_id] = params[:user_id] if params[:user_id].present?
    festival_my_timetable_path(params[:festival_id], options)
  end

  def my_timetables_back_path
    case action_name
    when "index"
      timetables_path
    when "show"
      my_timetables_path
    else
      identifier = params[:festival_id] || params[:id]
      identifier.present? ? timetable_path(identifier) : root_path
    end
  end

  def mypage_back_path
    mypage_path
  end
end

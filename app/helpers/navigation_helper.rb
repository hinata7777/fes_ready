module NavigationHelper
  def header_back_path
    return nil if current_page?(root_path)
    return @header_back_path if defined?(@header_back_path) && @header_back_path.present?

    case controller_path
    when "festivals"
      festivals_back_path
    when "artists"
      artists_back_path
    when "my_timetables"
      my_timetables_back_path
    else
      root_path
    end
  end

  private

  def festivals_back_path
    case params[:from]
    when "artist_festivals"
      return artist_festivals_path(params[:artist_id]) if params[:artist_id].present?
    when "timetables"
      return timetables_path
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
    timetable_festival_path(params[:festival_id], options)
  end

  def my_timetable_back_path
    return root_path if params[:festival_id].blank?
    options = {}
    options[:date] = params[:date] if params[:date].present?
    options[:user_id] = params[:user_id] if params[:user_id].present?
    my_timetable_festival_path(params[:festival_id], options)
  end

  def my_timetables_back_path
    case action_name
    when "index"
      timetables_path
    when "show"
      my_timetables_path
    else
      identifier = params[:festival_id] || params[:id]
      identifier.present? ? timetable_festival_path(identifier) : root_path
    end
  end
end

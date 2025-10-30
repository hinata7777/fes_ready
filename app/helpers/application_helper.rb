module ApplicationHelper
  include Pagy::Frontend
  include NavigationHelper

  def flash_class(key)
    case key.to_sym
    when :notice then "bg-emerald-600 text-white"
    when :alert  then "bg-rose-600 text-white"
    else              "bg-slate-800 text-white"
    end
  end

  def format_date_with_weekday(date)
    return if date.blank?

    weekday_names = %w[日 月 火 水 木 金 土]
    "#{date.strftime('%Y/%m/%d')}(#{weekday_names[date.wday]})"
  end
end

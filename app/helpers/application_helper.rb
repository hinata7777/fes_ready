module ApplicationHelper
  def flash_class(key)
    case key.to_sym
    when :notice then "bg-emerald-600 text-white"
    when :alert  then "bg-rose-600 text-white"
    else              "bg-slate-800 text-white"
    end
  end
end

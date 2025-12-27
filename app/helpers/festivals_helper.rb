module FestivalsHelper
  def status_labels
    # enumのキーをUI表示用ラベルに変換する（I18nがなければhumanizeにフォールバック）
    Festival.status_filters.keys.index_with do |key|
      I18n.t("enums.festival.status_filter.#{key}", default: key.humanize)
    end
  end
end

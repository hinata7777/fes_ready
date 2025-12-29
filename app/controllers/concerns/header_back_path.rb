module HeaderBackPath
  extend ActiveSupport::Concern

  private

  # back_to(絶対パス) > back_to(トークン) > default_back_path の順で戻り先を決める
  def set_header_back_path
    back = params[:back_to].to_s
    if back.present?
      @header_back_path =
        if back.start_with?("/")
          back
        else
          resolved_back_path(back)
        end
      return
    end

    @header_back_path = default_back_path
  end

  # コントローラ固有のトークン解決を上書きする
  def resolved_back_path(_token)
    nil
  end

  # back_to が無いときの既定の戻り先を上書きする
  def default_back_path
    nil
  end
end

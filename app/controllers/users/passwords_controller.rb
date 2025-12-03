class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :require_no_authentication, only: [ :create, :edit, :update ]

  def new
    self.resource = resource_class.new
    resource.email = current_user.email if user_signed_in?
    respond_with(resource)
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(reset_password_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_to do |format|
        format.html do
          redirect_path = user_signed_in? ? mypage_dashboard_path : after_sending_reset_password_instructions_path_for(resource_name)
          redirect_to redirect_path, notice: "パスワード再設定用メールを送信しました。"
        end
        format.all { head :ok }
      end
    else
      respond_with(resource)
    end
  end

  private

  def reset_password_params
    return { email: current_user.email } if user_signed_in?

    params.require(resource_name).permit(:email)
  end
end

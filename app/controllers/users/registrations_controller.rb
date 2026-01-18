class Users::RegistrationsController < Devise::RegistrationsController
  def update_resource(resource, params)
    return super if params["password"].present?

    resource.update_without_password(params.except("current_password"))
  end

  def destroy
    super do
      return redirect_to root_path, notice: "退会しました。ご利用ありがとうございました。"
    end
  end
end

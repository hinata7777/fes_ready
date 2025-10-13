class Admin::UsersController < Admin::BaseController
  def index
    @pagy, @users = pagy User.order(created_at: :desc)
  end
end

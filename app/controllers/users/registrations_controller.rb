class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :authenticate_scope!, only: [:edit, :update, :destroy, :finish_signup, :do_finish_signup]

  def create
    build_resource(sign_up_params)
    if resource.valid_with_captcha?
      super
    else
      render :new
    end
  end

  def delete_form
    build_resource({})
  end

  def delete
    current_user.erase(erase_params[:erase_reason])
    sign_out
    redirect_to root_url, notice: t("devise.registrations.destroyed")
  end

  def success
  end

  def finish_signup
    current_user.registering_with_oauth = false
    current_user.validate
  end

  def do_finish_signup
    current_user.registering_with_oauth = false
    current_user.validate
    should_send_confirmation = current_user.errors.include? :email
    if current_user.update(sign_up_params)
      current_user.send_confirmation_instructions if should_send_confirmation
      sign_in_and_redirect current_user, event: :authentication
    else
      render :finish_signup
    end
  end

  private

    def sign_up_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :captcha, :captcha_key, :terms_of_service)
    end

    def erase_params
      params.require(:user).permit(:erase_reason)
    end

    def after_inactive_sign_up_path_for(resource_or_scope)
      users_sign_up_success_path
    end

end

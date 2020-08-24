class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bitbucket
    Rails.logger.debug request.env['omniauth.auth']
    logger.debug request.env['omniauth.auth']
    @user = User.from_omniauth_bitbucket(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      if is_navigational_format?
        set_flash_message(:notice, :success, kind: 'Bitbucket')
      end
    else
      session['devise.bitbucket_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def github
    Rails.logger.debug request.env['omniauth.auth']
    logger.debug request.env['omniauth.auth']
    @user = User.from_omniauth_github(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      if is_navigational_format?
        set_flash_message(:notice, :success, kind: 'Github')
      end
    else
      session['devise.bitbucket_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end

module Dashboard
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_property_manager!

    private

    def require_property_manager!
      return if current_user.property_manager? || current_user.home_seeker?

      redirect_to root_path, alert: t('errors.not_authorized')
    end
  end
end

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        UserMailer.welcome_email(resource).deliver_later
      end
    end
  end
end

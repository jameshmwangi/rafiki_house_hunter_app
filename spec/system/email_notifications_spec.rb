require 'rails_helper'

RSpec.describe "Email Notifications", type: :system do
  include ActiveJob::TestHelper

  describe "welcome email on signup" do
    it "enqueues a welcome email after registration" do
      visit new_user_registration_path

      fill_in I18n.t('devise.labels.full_name'), with: "New User"
      fill_in I18n.t('devise.labels.email'), with: "newuser@wantu.africa"
      fill_in I18n.t('devise.labels.phone_number'), with: "0700123456"
      select I18n.t('roles.home_seeker'), from: I18n.t('devise.labels.role')
      fill_in I18n.t('devise.labels.password'), with: "password123"
      fill_in I18n.t('devise.labels.password_confirmation'), with: "password123"

      expect {
        click_button I18n.t('devise.registrations.new.sign_up')
      }.to have_enqueued_mail(UserMailer, :welcome_email)
    end

    it "does not enqueue an email when registration fails" do
      visit new_user_registration_path

      expect {
        click_button I18n.t('devise.registrations.new.sign_up')
      }.not_to have_enqueued_mail(UserMailer, :welcome_email)
    end
  end
end

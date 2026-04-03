require 'rails_helper'

RSpec.describe "Admin Dashboard", type: :system do
  let!(:admin) { create(:user, :admin) }
  let!(:regular_user) { create(:user) }
  let!(:location) { create(:location) }
  let!(:listing) { create(:listing, user: create(:user, :agent), location: location, status: "published") }

  describe "admin access" do
    it "allows admin to view the dashboard" do
      sign_in admin
      visit admin_root_path

      expect(page).to have_content("Wantu Admin")
      expect(page).to have_content(I18n.t('admin.users'))
      expect(page).to have_content(I18n.t('admin.listings'))
    end

    it "redirects non-admin users with an error" do
      sign_in regular_user
      visit admin_root_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(I18n.t('errors.not_authorized'))
    end
  end
end

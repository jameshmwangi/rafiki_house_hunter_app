class AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @appointments = current_user.viewing_appointments
                                .includes(:listing, :agent)
                                .order(scheduled_at: :desc)
                                .limit(5)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(account_params)
      redirect_to account_path, notice: t('users.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:full_name, :phone_number)
  end
end

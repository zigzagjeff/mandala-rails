class AccountClosuresController < ApplicationController
  def new
  end

  def create
    if Current.user.authenticate(params[:password])
      Current.user.close
      ClosureMailer.scheduled_later Current.user
      redirect_to account_path, notice: "Your account is scheduled for deletion on #{Current.user.deletes_on.to_date.to_fs(:long)}. Cancel any time before then."
    else
      redirect_to new_account_closure_path, alert: "Incorrect password."
    end
  end

  def destroy
    Current.user.reopen
    redirect_to account_path, notice: "Your account deletion has been cancelled."
  end
end

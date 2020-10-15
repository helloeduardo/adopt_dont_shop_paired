class ApplicationsController < ApplicationController
  def show
    @application = Application.find(params[:id])
    if params[:pet_name]
      @pets = Pet.where(name: params[:pet_name])
    else
      @pets = []
    end
  end

  def new
  end

  def create
    user = User.find_by(name: params[:user_name])
    if user
      app = user.applications.create(app_params)
      redirect_to "/applications/#{app.id}"
    else
      flash.notice = "Invalid User Name"
      redirect_to "/applications/new"
    end
  end

  def update
    application = Application.find(params[:id])
    pet = Pet.find(params[:pet])
    application.pets << pet
    redirect_to "/applications/#{application.id}"
  end

  private
  def app_params
    params.permit(:status)
  end
end
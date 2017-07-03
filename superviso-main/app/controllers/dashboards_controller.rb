class DashboardsController < ::ApplicationController
  before_action :authenticate_user!, except: :script
  layout "only_dashing", only: :show
  def index
    
    @new_dashboard = Dashboard.new
    @templates = Dashboard.templates

    @dashboards = current_user.dashboards
  end

  def show
    @dashboard = current_user.dashboards.find(params[:id])
  end

  def edit
    @dashboard = current_user.dashboards.find(params[:id])
  end

  def create
    @dashboard = build_dashbaord_empty_or_from_template 
    if @dashboard.save
      flash[:success] = "Dashboard created."
      redirect_to edit_dashboard_path(@dashboard)
    else
      flash[:error] = "Was not possible to create a new dashboard."
      redirect_to dashboards_path
    end
  end

  def update
    @dashboard = current_user.dashboards.find(params[:id])
    if @dashboard.update_attributes(dashboard_params_update)
      render json: {success: :ok}
    else
      render json: {error: @dashboard.errors}
    end
  end

  def destroy
    @dashboard = current_user.dashboards.find(params[:id])
    @dashboard.destroy
    flash[:success] = "Dashboard destroyed."
    redirect_to dashboards_path
  end

  def script 
    @dashboard = Dashboard.find_by_uid(params[:uid])
    respond_to do |format|
      format.sh 
    end
  end

  private
  def dashboard_params
    params.require("dashboard").permit(:name)
  end
  def dashboard_params_update
    params.require("dashboard").permit(:name, widgets_attributes: [:id, :row, :col])
  end
  
  def build_dashbaord_empty_or_from_template
    if params["dashboard"] and params["dashboard"]["template"]
      template = Dashboard.where(user_id: nil, id: params["dashboard"]["template"]).limit(1).first
      params["dashboard"].delete("template")
      unless template.nil?
        dashboard = Dashboard.build_from_template(template)
        dashboard.assign_attributes(dashboard_params.merge({user_id: current_user.id,
        cloned_from: template, uid: SecureRandom.hex }))
        return dashboard
      end
    end

    current_user.dashboards.build(dashboard_params)
  end
end

class WidgetsController < ::ApplicationController
  before_action :authenticate_user!
  def show
    @dashboard = current_user.dashboards.find(params[:dashboard_id])
    @widget = @dashboard.widgets.find(params[:id])
  end
  def new
    @dashboard = current_user.dashboards.find(params[:dashboard_id])
    @widget = @dashboard.widgets.build(type: params[:type])
  end
  def edit
    @dashboard = current_user.dashboards.find(params[:dashboard_id])
    @widget = @dashboard.widgets.find(params[:id])
  end
  def create
    @dashboard = current_user.dashboards.find(params[:dashboard_id])
    @widget = @dashboard.widgets.build(widget_params)
    if @widget.save
      flash[:success] = "Widget created."
      redirect_to edit_dashboard_path(@dashboard)
    else
      flash[:error] = "Was not possible to create a new widget."
      redirect_to edit_dashboard_path(@dashboard)
    end
  end
  def update
    @dashboard = current_user.dashboards.find(params[:dashboard_id])
    @widget = @dashboard.widgets.find(params[:id])
    if @widget.update_attributes(widget_params)
      flash[:success] = "Widget updated."
      redirect_to edit_dashboard_path(@dashboard)
    else
      flash[:error] = "Was not possible to update the widget."
    end
  end

  def destroy
    @dashboard = current_user.dashboards.find(params[:dashboard_id])
    @widget = @dashboard.widgets.find(params[:id])
    if @widget.deletable
      @widget.destroy
      flash[:success] = "Widget destroyed."
    else
      flash[:error] = "It's not possible to destroy widgets defined in a template"
    end
    redirect_to edit_dashboard_path(@dashboard)
  end

  private
  def widget_params
    if params[:type]
      widget_type = params[:type].underscore.gsub("/", "_")
    else
      widget_type = @widget.type.underscore.gsub("/", "_")
    end
    params.require(widget_type).permit(:type, :size_x, :size_y, :color, :title, :text, :moreinfo, :series, :categories, 
                                       :current, :last, :prefix, :date, :time, :end_date, :location, :code, :unit, 
                                       :temperature, :max_value, :current_value, :progress_items, :items, :suffix,:max, :min, :current_value, :value_1, :value_2, :value_3)

  end
end

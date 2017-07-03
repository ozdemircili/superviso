require 'spec_helper'

describe "Dashboards" do
  it "requires authentication" do
    logout(:user)
    visit dashboards_path
    expect(current_path).to eq(new_user_session_path)
  end

  context "When authenticated" do
    let(:user){FactoryGirl.create(:user)}

    before :each do
      3.times{create :dashboard, user: user}
      2.times{create :dashboard, user: create(:user)}
      @template = create(:template, name: "Cool Template", widgets: [build(:widget_text)])
      login_as(user, :scope => :user)
      visit dashboards_path
    end
    it "Has a link to create new dashboards" do
      expect(page).to have_css(".btn-create-dashboard")
    end
    
    it "Shows all existing dashboards" do
      expect(page).to have_css(".dashboards")
      expect(page).to have_css(".panel-dashboard", count: 3)
    end

    it "Shows actions for each dashboard" do
      expect(page).to have_css(".panel-dashboard .btn-group", count: 3)
      expect(page).to have_css(".panel-dashboard .btn-group .btn-dashboard-view", count: 3)
      expect(page).to have_css(".panel-dashboard .btn-group .btn-dashboard-edit", count: 3)
      expect(page).to have_css(".panel-dashboard .btn-group .btn-dashboard-destroy", count: 3)
    end

    it "Shows a modal when user click on New Dashboard" do
      expect(page).to have_selector("#create-dashboard", visible: false)
      click_link("New Dashboard")
      expect(page).to have_selector("#create-dashboard", visible: true)
    end

    context "Create dashboard" do
      it "redirects to edit" do
        click_link("New Dashboard")
        fill_in "Name", with: "cool name"
        click_button "Create"
        expect(current_path).to eq(edit_dashboard_path(Dashboard.last)) 
        expect(page).to have_content("Dashboard created.") 
      end
    end
    
    context "Create dashboard from template" do
      it "cones template and redirects to edit" do
        click_link("New Dashboard")
        fill_in "Name", with: "dolly"
        select("Cool Template", from: "dashboard_template")
        click_button "Create"
        expect(current_path).to eq(edit_dashboard_path(Dashboard.last)) 
        expect(@template.widgets.count).to eq(1)
        expect(page).to have_css(".dashing-widget", count: 1)
        expect(page).to have_content("Dashboard created.") 

        expect(page).to_not have_link("Destroy")
      end
    end
    
    context "Edit dashboard" do
      let(:dashboard) {create(:dashboard, user: user)}
      let(:widget) {create(:widget_text, dashboard: dashboard)}

      before :each do
        widget
        visit edit_dashboard_path(dashboard )
      end
    
      it "shows all the widget associated to the dashboard" do
        expect(page).to have_css("div.gridster > ul > li", count: 1)
      end

      it "has a button to add widgets" do
        expect(page).to have_content("Add Widget")  
      end
    end
  end
end

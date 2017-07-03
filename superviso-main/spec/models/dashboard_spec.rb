require 'spec_helper'

describe Dashboard do
  it { should belong_to(:user) }
  it { should have_many(:widgets) }

  context "#next_coordintes" do
    let(:dashboard){create(:dashboard)}
    context "No widgets" do
      it "returns 1 1" do
        expect(dashboard.next_coordintes).to eq({col: 1, row: 1})
      end
    end

    context "With widget" do
      it "returns col and row" do
        widget = create(:widget_text, dashboard: dashboard)
        expect(dashboard.next_coordintes).to eq({col: 1, row: 2})
      end
    end
  end
  context "#templates" do
    before :each do
      create(:dashboard)
    end
    it "returns only the templates" do
      template = create(:template)
      expect(Dashboard.templates.count).to eq(1)
      expect(Dashboard.templates.first).to eq(template)
    end
  end

  context "#build_from_template" do
    let(:template) {create(:template, widgets: [build(:widget)])}

    it "builds a dashboard from a template" do
      expect(template.widgets.count).to eq(1)

      dashboard = Dashboard.build_from_template(template)
      dashboard.save
      
      expect(dashboard.widgets.count).to eq(template.widgets.count)
      dashboard.widgets.each do |widget|
        expect(widget.deletable).to eq(false)
      end
    end
  end
end

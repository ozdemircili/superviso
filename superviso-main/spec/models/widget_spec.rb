require 'spec_helper'

describe Widget do
  it { should belong_to(:dashboard) }

  context "#secret_token" do
    it "generate secret_token is called before create" do
      widget = build(:widget)
      widget.should_receive(:generate_secret_token)
      widget.save
    end
    it "is valorized on create" do
      widget = create(:widget)
      expect(widget.secret_token).to_not be_nil
    end
    it "doesn't change on update" do
      widget = create(:widget)
      secret_token = widget.secret_token 
      widget.update_attributes({name: "Widget Name"})
      expect(widget.secret_token).to eq(widget.secret_token)
    end
  end
end

describe Widgets::Text do
  it "sets a proper type" do
    widget = create(:widget_text)
    expect(widget.type).to eq("Widgets::Text")
  end
  
  it "sets a proper col and row" do
    dashboard = create(:dashboard)
    create(:widget, dashboard: dashboard)
    widget = create(:widget, dashboard: dashboard)
    expect(widget.col).to eq(1)
    expect(widget.row).to eq(2)
  end

  it "has settings" do
    widget = create(:widget_text)
    expect(widget.color).to eq("#00ff00")
    expect(widget.title).to eq("title")
  end
  context "#dashing_type" do
    it "return the dashing type" do
      widget = create(:widget_text)
      expect(widget.dashing_type).to eq("Text")
    end
  end
  
  context "dashing_data_hash" do
    it "returns an hash with widget values" do
      widget = create(:widget_text)
      expect(widget.dashing_data_hash).to be_kind_of(Hash)
      expect(widget.dashing_data_hash[:id]).to eq(widget.secret_token)
      expect(widget.dashing_data_hash[:view]).to eq(widget.dashing_type)
      expect(widget.dashing_data_hash[:title]).to eq("title")
    end

    it "merges the last received values with default values" do
      redis = Redis.new
      redis.ping
      widget = create(:widget_text)
      redis.set "w:#{widget.secret_token}:last", {id: "maliciousvalue", title: "XXX", 
                                                  text: "YYY", moreinfo: "ZZZ"}.to_json
      expect(widget.dashing_data_hash[:id]).to eq(widget.secret_token)
      expect(widget.dashing_data_hash[:title]).to eq("XXX")
    end
  end
end

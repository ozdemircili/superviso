require 'spec_helper'

describe AsciicastPagePresenter do

  describe '.build' do
    subject { described_class.build(asciicast, user, playback_options) }

    let(:asciicast) { stub_model(Asciicast, decorate: decorated_asciicast) }
    let(:user) { double('user') }
    let(:playback_options) { { speed: 3.0 } }
    let(:decorated_asciicast) { double('decorated_asciicast') }

    it "builds presenter with given asciicast decorated" do
      expect(subject.asciicast).to be(decorated_asciicast)
    end

    it "builds presenter with given user" do
      expect(subject.current_user).to be(user)
    end

    it "builds presenter with given playback options" do
      expect(subject.playback_options.speed).to eq(3.0)
    end
  end

  let(:presenter) { described_class.new(asciicast, current_user, nil) }
  let(:asciicast) { stub_model(Asciicast, user: author) }
  let(:current_user) { User.new }
  let(:author) { User.new }

  let(:view_context) {
    controller = ApplicationController.new
    controller.request = ActionController::TestRequest.new
    controller.view_context
  }

  describe '#title' do
    subject { presenter.title }

    before do
      allow(asciicast).to receive(:title) { 'the-title' }
    end

    it { should eq('the-title') }
  end

  describe '#asciicast_title' do
    subject { presenter.asciicast_title }

    before do
      allow(asciicast).to receive(:title) { 'the-title' }
    end

    it { should eq('the-title') }
  end

  describe '#author_img_link' do
    subject { presenter.author_img_link }

    before do
      allow(asciicast).to receive(:author_img_link) { '<a href=...>' }
    end

    it { should eq('<a href=...>') }
  end

  describe '#author_link' do
    subject { presenter.author_link }

    before do
      allow(asciicast).to receive(:author_link) { '<a href=...>' }
    end

    it { should eq('<a href=...>') }
  end

  describe '#asciicast_created_at' do
    subject { presenter.asciicast_created_at }

    let(:now) { Time.now }

    before do
      allow(asciicast).to receive(:created_at) { now }
    end

    it { should eq(now) }
  end

  describe '#asciicast_env_details' do
    subject { presenter.asciicast_env_details }

    before do
      allow(asciicast).to receive(:os) { 'Linux' }
      allow(asciicast).to receive(:shell) { 'bash' }
      allow(asciicast).to receive(:terminal_type) { 'xterm' }
    end

    it { should eq('Linux / bash / xterm') }
  end

  describe '#views_count' do
    subject { presenter.views_count }

    before do
      allow(asciicast).to receive(:views_count) { 5 }
    end

    it { should eq(5) }
  end

  describe '#embed_script' do
    subject { presenter.embed_script(view_context) }

    let(:src_regexp) { /src="[^"]+\b123\b[^"]*\.js"/ }
    let(:id_regexp) { /id="asciicast-123"/ }
    let(:script_regexp) {
      /^<script[^>]+#{src_regexp}[^>]+#{id_regexp}[^>]*><\/script>/
    }

    before do
      allow(asciicast).to receive(:id).and_return(123)
    end

    it 'is an async script tag including asciicast id' do
      expect(subject).to match(script_regexp)
    end
  end

  describe '#show_admin_dropdown?' do
    subject { presenter.show_admin_dropdown? }

    before do
      allow(asciicast).to receive(:managable_by?).
        with(current_user) { managable }
    end

    context "when asciicast can't be managed by the user" do
      let(:managable) { false }

      it { should be(false) }
    end

    context "when asciicast can be managed by the user" do
      let(:managable) { true }

      it { should be(true) }
    end
  end

  describe '#show_description?' do
    subject { presenter.show_description? }

    before do
      allow(asciicast).to receive(:description) { description }
    end

    context "when description is present" do
      let(:description) { 'i am description' }

      it { should be(true) }
    end

    context "when description isn't present" do
      let(:description) { '' }

      it { should be(false) }
    end
  end

  describe '#description' do
    subject { presenter.description }

    before do
      allow(asciicast).to receive(:description) { 'i am description' }
    end

    it { should eq('i am description') }
  end

  describe '#show_other_asciicasts_by_author?' do
    subject { presenter.show_other_asciicasts_by_author? }

    before do
      allow(author).to receive(:asciicast_count) { count }
    end

    context "when user has more than 1 asciicast" do
      let(:count) { 2 }

      it { should be(true) }
    end

    context "when user doesn't have more than 1 asciicasts" do
      let(:count) { 1 }

      it { should be(false) }
    end
  end

  describe '#other_asciicasts_by_author' do
    subject { presenter.other_asciicasts_by_author }

    let(:others) { double('others', decorate: decorated_others) }
    let(:decorated_others) { double('decorated_others') }

    before do
      allow(author).to receive(:asciicasts_excluding).
        with(asciicast, 3) { others }
    end

    it "returns decorated asciicasts excluding the given one" do
      expect(subject).to be(decorated_others)
    end
  end

end

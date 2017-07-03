require 'spec_helper'
require 'tempfile'

describe Asciicast do

  describe '.for_category_ordered' do
    subject { described_class.for_category_ordered(category, order) }

    let!(:asciicast_1) { create(:asciicast, created_at:  2.hours.ago,
                                            views_count: 10,
                                            featured:    false) }
    let!(:asciicast_2) { create(:asciicast, created_at:  1.hour.ago,
                                            views_count: 20,
                                            featured:    true) }
    let!(:asciicast_3) { create(:asciicast, created_at:  4.hours.ago,
                                            views_count: 30,
                                            featured:    false) }
    let!(:asciicast_4) { create(:asciicast, created_at:  3.hours.ago,
                                            views_count: 40,
                                            featured:    true) }

    context "when category is :all" do
      let(:category) { :all }

      context "and order is :recency" do
        let(:order) { :recency }

        it { should eq([asciicast_2, asciicast_1, asciicast_4, asciicast_3]) }
      end

      context "and order is :popularity" do
        let(:order) { :popularity }

        it { should eq([asciicast_4, asciicast_3, asciicast_2, asciicast_1]) }
      end
    end

    context "when category is :featured" do
      let(:category) { :featured }

      context "and order is :recency" do
        let(:order) { :recency }

        it { should eq([asciicast_2, asciicast_4]) }
      end

      context "and order is :popularity" do
        let(:order) { :popularity }

        it { should eq([asciicast_4, asciicast_2]) }
      end
    end
  end

  let(:asciicast) { described_class.new }

  describe '#user' do
    subject { asciicast.user }

    context "when it has user assigned" do
      let(:user) { User.new }

      before do
        asciicast.user = user
      end

      it { should be(user) }
    end

    context "when it doesn't have user assigned" do
      it 'is a dummy user' do
        expect(asciicast.user).to be_dummy
      end

      it 'is a user with "anonymous" as username' do
        expect(asciicast.user.username).to eq('anonymous')
      end
    end
  end

  describe '#stdout' do
    let(:asciicast) { Asciicast.new }
    let(:data_uploader) { double('data_uploader',
                                 :decompressed_path => '/foo') }
    let(:timing_uploader) { double('timing_uploader',
                                   :decompressed_path => '/bar') }
    let(:stdout) { double('stdout', :lazy => lazy_stdout) }
    let(:lazy_stdout) { double('lazy_stdout') }

    subject { asciicast.stdout }

    before do
      allow(BufferedStdout).to receive(:new) { stdout }
      allow(StdoutDataUploader).to receive(:new) { data_uploader }
      allow(StdoutTimingUploader).to receive(:new) { timing_uploader }
    end

    it 'creates a new BufferedStdout instance' do
      subject

      expect(BufferedStdout).to have_received(:new).with('/foo', '/bar')
    end

    it 'returns lazy instance of stdout' do
      expect(subject).to be(lazy_stdout)
    end
  end

  describe '#managable_by?' do
    subject { asciicast.managable_by?(user) }

    let(:asciicast) { Asciicast.new }
    let(:owner) { nil }

    before do
      asciicast.user = owner
    end

    context "when user is nil" do
      let(:user) { nil }

      it { should be(false) }
    end

    context "when user is owner of the asciicast" do
      let(:user) { User.new }
      let(:owner) { user }

      it { should be(true) }
    end

    context "when user isn't owner of the asciicast" do
      let(:user) { User.new }
      let(:owner) { User.new }

      it { should be(false) }
    end
  end

end

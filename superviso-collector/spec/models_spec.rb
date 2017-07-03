require 'spec_helper'

describe "Database Connection" do
  it "works" do
    expect(User.all.count).to be_kind_of(Integer)
  end
end

describe User do
end

describe Widget do
end



require 'spec_helper'

RSpec.describe SimplestStatus do
  class EmptyModel
    extend SimplestStatus
  end

  before do
    allow(EmptyModel).to receive(:include).with(SimplestStatus::ModelMethods)
  end

  it "has a version number" do
    expect(SimplestStatus::VERSION).not_to be nil
  end

  context "when extended by a model" do
    it "adds the .statuses method" do
      expect(EmptyModel.statuses(:boom, :shaka, :laka)).to eq(:boom => 0, :shaka => 1, :laka => 2)
    end
  end

  describe ".statuses" do
    it "adds the .all_statuses method" do
      EmptyModel.statuses(:boom, :shaka, :laka)
      expect(EmptyModel.all_statuses).to eq(:boom => 0, :shaka => 1, :laka => 2)
    end

    it "adds the .status_column_name method" do
      EmptyModel.statuses(:boom, :shaka, :laka)
      expect(EmptyModel.status_column_name).to eq(:status)
    end

    it "sets class variable status_column_name as given in options" do
      EmptyModel.statuses(:boom, :shaka, :laka, column_name: :status_id)
      expect(EmptyModel.status_column_name).to eq(:status_id)
    end
  end
end

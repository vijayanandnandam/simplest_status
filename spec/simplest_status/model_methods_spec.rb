require 'spec_helper'

RSpec.describe SimplestStatus::ModelMethods do
  class MockModel < Struct.new(:status)
    class << self
      attr_accessor :validation_input

      def validates(field, options)
        self.validation_input = options.merge(:field => field)
      end

      def all_statuses
        SimplestStatus::StatusCollection[:boom, 1, :shaka, 2, :laka, 3]
      end

      def status_column_name
        :status
      end
    end

    include SimplestStatus::ModelMethods

    def status
      self.class.all_statuses[super]
    end
  end

  describe "when included in a model" do
    it "sets a constant for each status" do
      expect(MockModel::BOOM).to eq 1
      expect(MockModel::SHAKA).to eq 2
      expect(MockModel::LAKA).to eq 3
    end

    it "defines a class-level scopes" do
      expect(MockModel).to receive(:where).with(:status => 2)

      MockModel.shaka
    end

    it "defines instance-level predicate methods" do
      expect(MockModel.new(:boom).boom?).to eq true
      expect(MockModel.new(:shaka).boom?).to eq false
      expect(MockModel.new(:laka).boom?).to eq false
    end

    # it "defines instance-level status mutation methods" do
    #   MockModel.new(:boom).tap do |subject|
    #     expect(subject).to receive(:update_attributes).with(:status => 2)
    #
    #     subject.laka
    #   end
    # end

    it "defines an instance-level #status_label method" do
      expect(MockModel.new(:boom).status_label).to eq 'Boom'
      expect(MockModel.new(:shaka).status_label).to eq 'Shaka'
      expect(MockModel.new(:laka).status_label).to eq 'Laka'
    end

    it "sets up the correct model validations" do
      MockModel.validation_input.tap do |validation|
        expect(validation[:field]).to eq :status
        expect(validation[:presence]).to eq true
        expect(validation[:inclusion][:in].call).to eq [1, 2, 3]
      end
    end
  end
end

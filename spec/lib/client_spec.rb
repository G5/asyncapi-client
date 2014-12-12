require "spec_helper"

module Asyncapi
  describe Client do

    describe ".configure" do
      it "allows for a configuration DSL" do
        described_class.configure do |c|
          described_class::CONFIG_ATTRS.each do |attr|
            c.send(:"#{attr}=", "myvalfor#{attr}")
          end
        end

        described_class::CONFIG_ATTRS.each do |attr|
          expect(described_class.send(attr)).to eq "myvalfor#{attr}"
        end
      end
    end

    describe ".parent_controller" do
      it "defaults to ActionController::Base if nil" do
        described_class.parent_controller = nil
        expect(described_class.parent_controller).to eq ActionController::Base
      end
    end

  end
end

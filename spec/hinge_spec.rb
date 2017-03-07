require 'hinge'

describe Hinge do
  describe "resolver" do
    it "returns a resolver" do
      expect(
        described_class.resolver(nil)
      ).to be_an_instance_of(Hinge::Resolver)
    end
  end
end

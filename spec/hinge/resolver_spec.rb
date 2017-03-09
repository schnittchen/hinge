require 'hinge/resolver'

describe Hinge::Resolver do
  it "has the container attribute" do
    container = "foo"
    expect(described_class.new(container).container).to be_equal(container)
  end

  describe "initially" do
    it "has nothing resolved" do
      container = "foo"
      expect(described_class.new(container).resolved).to eql({})
    end
  end

  describe "with some container" do
    subject do
      described_class.new(container)
    end

    describe "the second simplest case" do
      let(:container) do
        container = Object.new
        def container.build_simple
          "simple"
        end
        container
      end

      describe "resolve" do
        it "does not like string names" do
          # I like to keep things simple. Use symbols instead!
          expect {
            subject.resolve("simple")
          }.to raise_exception(ArgumentError)
        end

        it "resolves a leaf value correctly" do
          expect(
            subject.resolve(:simple)
          ).to eql(container.build_simple)

          expect(
            subject.resolved[:simple]
          ).to eql(container.build_simple)
        end

        it "produces an equal value the second time" do
          expect(
            subject.resolve(:simple)
          ).to equal(subject.resolve(:simple))
        end

        it "raises when the container does not have a prefixed method" do
          expect {
            subject.resolve(:similar)
          }.to raise_exception(described_class::UnknownDependency)
        end
      end
    end

    describe "with a simple dependency" do
      let(:container) do
        container = Object.new
        def container.build_root(leaf)
          "root " + leaf
        end
        def container.build_leaf
          "leaf"
        end
        container
      end

      it "resolves correctly" do
        expect(
          subject.resolve(:root)
        ).to eql("root leaf")
      end
    end

    describe "with two distinct paths from root to the same dependency" do
      let(:container) do
        container = Object.new
        def container.build_root(dep1, dep2)
          Struct.new(:dep1, :dep2).new(dep1, dep2)
        end
        def container.build_dep1(leaf)
          Struct.new(:leaf).new(leaf)
        end
        def container.build_dep2(leaf)
          Struct.new(:leaf).new(leaf)
        end
        def container.build_leaf
          "leaf"
        end
        container
      end

      it "resolves correctly" do
        root = subject.resolve(:root)

        expect(root.dep1.leaf).to equal(root.dep2.leaf)
      end
    end

    describe "with a missing dependency" do
      let(:container) do
        container = Object.new
        def container.build_root(leaf)
        end
        container
      end

      it "detects incompleteness" do
        expect {
          subject.resolve(:root)
        }.to raise_exception(described_class::UnknownDependency)
      end
    end

    describe "with a self-referential method" do
      let(:container) do
        container = Object.new
        def container.build_root(root)
        end
        container
      end

      it "detects loop" do
        expect {
          subject.resolve(:root)
        }.to raise_exception(described_class::CircularReference)
      end
    end

    describe "with a loop spanning more than one dependency" do
      let(:container) do
        container = Object.new
        def container.build_leaf(root)
        end
        def container.build_root(leaf)
        end
        container
      end

      it "detects loop" do
        expect {
          subject.resolve(:root)
        }.to raise_exception(described_class::CircularReference)
      end
    end

    describe "possible argument names" do
      let(:container) do
        container = Object.new
        def container.build_positional
          :positional
        end
        def container.build_named
          :named
        end
        def container.build_root(positional, named)
          [positional, named]
        end
        container
      end

      it "resolves both positional and named arguments" do
        expect(
          subject.resolve(:root)
        ).to eql([:positional, :named])
      end
    end
  end

end


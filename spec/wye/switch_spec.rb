require 'spec_helper'

describe Wye::Switch do
  let(:base_class) { Class.new }
  let(:derived_class) { Class.new(base_class) }
  let(:switch) { Wye::Switch.new(base_class) }

  describe "#initialize" do
    subject { switch }

    its(:base_class) { should be(base_class) }
  end

  describe "#current_alternate" do
    let(:alternate) { 'alt1' }

    subject { switch.current_alternate(klass) }

    around(:each) do |example|
      switch.current_alternate(klass).should be_nil
      switch.on(class_with_alternate, alternate) { example.run }
      switch.current_alternate(klass).should be_nil
    end

    context "with an alternate on the base class" do
      let(:class_with_alternate) { base_class }

      context "given the base class" do
        let(:klass) { base_class }
        it { should == alternate }

        context "with a nested alternate on the base class" do
          let(:nested_alternate) { 'alt2' }

          around(:each) do |example|
            switch.current_alternate(klass).should == alternate
            switch.on(class_with_alternate, nested_alternate) { example.run }
            switch.current_alternate(klass).should == alternate
          end

          it { should == nested_alternate }
        end
      end

      context "given the derived class" do
        let(:klass) { derived_class }
        it { should == alternate }
      end
    end

    context "with an alternate on the derived class" do
      let(:class_with_alternate) { derived_class }

      context "given the base class" do
        let(:klass) { base_class }
        it { should be_nil }
      end

      context "given the derived class" do
        let(:klass) { derived_class }
        it { should == alternate }
      end
    end

    context "with a nested alternate" do
      subject { switch.current_alternate(nested_klass) }

      let(:nested_alternate) { 'alt2' }
      let(:klass) { class_with_alternate }

      around(:each) do |example|
        switch.current_alternate(nested_klass).should == alternate
        switch.on(class_with_nested_alternate, nested_alternate) { example.run }
        switch.current_alternate(nested_klass).should == alternate
      end

      context "where the first is on the base class" do
        let(:class_with_alternate) { base_class }

        context "and the second is on the base class" do
          let(:class_with_nested_alternate) { base_class }

          context "given the base class" do
            let(:nested_klass) { base_class }
            it { should == nested_alternate }
          end
        end

        context "and the second is on the derived class" do
          let(:class_with_nested_alternate) { derived_class }

          context "given the base class" do
            let(:nested_klass) { base_class }
            it { should == alternate }
          end

          context "given the derived class" do
            let(:nested_klass) { derived_class }
            it { should == nested_alternate }
          end
        end
      end
    end

    pending "thread safety"
  end
end

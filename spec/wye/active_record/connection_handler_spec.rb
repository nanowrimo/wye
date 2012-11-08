require 'spec_helper'

module Wye::ActiveRecord
  describe ConnectionHandler do
    let(:handler) { ConnectionHandler.new }

    subject { handler }

    let(:base_klass) { ActiveRecord::Base }
    let(:derived_klass) { Class.new(base_klass).tap { |klass| klass.stub(:name) { 'Klass' } } }

    let(:klass) { base_klass }

    let(:config) { {:adapter => 'sqlite3', :database => ':memory:', :alternates => alternates} }
    let(:alternates) { {'a1' => {'database' => ''}, 'a2' => {'database' => '', 'pool' => 1}} }
    let(:adapter_method) { "#{config[:adapter]}_connection" }

    let(:spec) { ActiveRecord::Base::ConnectionSpecification.new(config, adapter_method) }

    describe "#initialize" do
      its(:switch) { should be_a(::Wye::Switch) }
      its(:connection_pools) { should be_a(Hash) }
      its(:connection_pools) { should be_empty }
    end

    describe "#establish_connection" do
      subject { handler.establish_connection(klass.name, spec) }

      it { should be_a(ActiveRecord::ConnectionAdapters::ConnectionPool) }
      its(:spec) { should be(spec) }
    end

    describe "#remove_connection" do
      subject { handler.remove_connection(klass) }
    end

    describe "#alternates" do
      subject { handler.alternates }

      context "after a connection is established with 2 alternates" do
        before(:each) { handler.establish_connection(klass.name, spec) }

        it { should be_a(Array) }
        it { should include(:a1) }
        it { should include(:a2) }
      end
    end

    describe "#connection_pools" do
      subject { handler.connection_pools.values }

      context "after a connection is established with 2 alternates" do
        before(:each) { handler.establish_connection(klass.name, spec) }

        its(:length) { should == 3 }

        its("first.spec") { should be(spec) }
        its("second.spec") { should_not be(spec) }
        its("third.spec") { should_not be(spec) }

        its("first.spec.config") { should == config }
        its("second.spec.config") { should == {:adapter => 'sqlite3', :database => ''} }
        its("third.spec.config") { should == {:adapter => 'sqlite3', :database => '', :pool => 1} }

        its("second.spec.config") { should_not include(:alternates) }
        its("third.spec.config") { should_not include(:alternates) }

        its("second.spec.config") { should satisfy { |config| config[:database] == '' } }
        its("third.spec.config") { should satisfy { |config| config[:database] == '' } }

        context "and then removed" do
          before(:each) { handler.remove_connection(klass) }

          it { should be_empty }
        end
      end
    end

    describe "#retrieve_alternate_connection_pool" do
      subject { handler.retrieve_alternate_connection_pool(klass, alternate) }

      context "after a connection is established with 2 alternates" do
        before(:each) { handler.establish_connection(base_klass.name, spec) }

        context "given an existing alternate" do
          let(:alternate) { :a1 }
          let(:alternate_pool) { handler.connection_pools.values.second }

          it { should be_a(ActiveRecord::ConnectionAdapters::ConnectionPool) }
          it { should be(alternate_pool) }

          context "and a derived class" do
            let(:klass) { derived_klass }

            it { should be_a(ActiveRecord::ConnectionAdapters::ConnectionPool) }
            it { should be(alternate_pool) }
          end
        end

        context "given a non-existent alternate" do
          let(:alternate) { 'x' }

          it { should be_nil }
        end
      end
    end

    describe "#retrieve_main_connection_pool" do
      subject { handler.retrieve_main_connection_pool(klass) }

      context "after a connection is established with 2 alternates" do
        before(:each) { handler.establish_connection(base_klass.name, spec) }

        let(:main_pool) { handler.connection_pools.values.first }

        it { should be_a(ActiveRecord::ConnectionAdapters::ConnectionPool) }
        it { should be(main_pool) }

        context "given a derived class" do
          let(:klass) { derived_klass }

          it { should be_a(ActiveRecord::ConnectionAdapters::ConnectionPool) }
          it { should be(main_pool) }
        end
      end
    end

    describe "#retrieve_connection_pool" do
      subject { handler.retrieve_connection_pool(klass) }

      context "after a connection is established with 2 alternates" do
        before(:each) do
          handler.establish_connection(base_klass.name, spec)
          handler.switch.should_receive(:current_alternate).and_return(alternate)
        end

        context "and an existing alternate is switched on" do
          let(:alternate) { :a1 }

          it("retrieves the alternate connection pool") do
            handler.should_receive(:retrieve_alternate_connection_pool).with(klass, alternate)
            subject
          end
        end

        context "and a non-existent alternate is switched on" do
          let(:alternate) { 'x' }

          it { should be_nil }
        end

        context "and no alternate is switched on" do
          let(:alternate) { nil }

          it("retrieves the main connection pool") do
            handler.should_receive(:retrieve_main_connection_pool).with(klass)
            subject
          end
        end
      end
    end
  end
end

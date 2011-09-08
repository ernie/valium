require 'spec_helper'

describe Valium do

  context 'with a symbol' do
    subject { Person.value_of :id }
    it { should have(100).ids }
    it { should eq((1..100).to_a) }
  end

  context 'with a string' do
    subject { Person.value_of 'id' }
    it { should have(100).ids }
    it { should eq((1..100).to_a) }
  end

  context 'with multiple values' do
    subject { Person.values_of :id, :last_name }
    it { should have(100).elements }
    it { should eq((1..100).map {|n| [n, "Number#{n}"]})}
  end

  context 'with a datetime column' do
    subject { Person.value_of :created_at }
    it { should have(100).datetimes }
    it { should be_all {|d| Time === d}}
  end

  context 'with a serialized column' do
    subject { Person.value_of :extra_info }
    it { should have(100).hashes }
    it { should eq 1.upto(100).map {|n| {:a_key => "Value Number #{n}"} }}
  end

  context 'with an alternate primary key and an :id select' do
    subject { Widget.value_of :id }
    it { should have(100).ids }
    it { should eq((1..100).to_a)}
  end

  context 'with an alternate primary key and an alternate primary key select' do
    subject { Widget.value_of :widget_id }
    it { should have(100).ids }
    it { should eq((1..100).to_a)}
  end

  context 'with a scope' do
    subject { Person.where(:id => [1,50,100]).value_of :last_name }
    it { should have(3).last_names }
    it { should eq ['Number1', 'Number50', 'Number100'] }
  end

  context 'with a scope and value_of syntax' do
    subject { Person.where(:id => [1,50,100]).value_of :id }
    it { should have(3).ids }
    it { should eq [1,50,100] }
  end

  context 'with a scope, an alternate primary key, and an :id select' do
    subject {Widget.where(:widget_id => [1,50,100]).value_of :id }
    it { should have(3).ids }
    it { should eq [1,50,100]}
  end

  context 'with a scope, an alternate primary key, and an alternate primary key select' do
    subject { Widget.where(:widget_id => [1,50,100]).value_of :widget_id }
    it { should have(3).widget_ids }
    it { should eq [1,50,100]}
  end

  context 'with a loaded scope' do
    subject do
      Person.where(:id => [1,50,100]).tap do |relation|
        relation.all
      end
    end

    # We'll generate the first query when we call "subject", but won't
    # need another query
    specify { queries_for { subject.value_of :id }.should have(1).query }

    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Person.where(:id => [1,50,100]).values_of(:id, :created_at, :extra_info) }
  end

  context 'with a loaded scope, an alternate primary key, and an :id select' do
    subject do
      Widget.where(:widget_id => [1,50,100]).tap do |relation|
        relation.all
      end
    end

    # We'll generate the first query when we call "subject", but won't
    # need another query
    specify { queries_for { subject.value_of :id }.should have(1).query }

    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Widget.where(:widget_id => [1,50,100]).values_of(:id, :created_at, :extra_info) }
  end

  context 'with a loaded scope but missing attributes' do
    subject do
      Person.select(:id).where(:id => [1,50,100]).tap do |relation|
        relation.all
      end
    end

    # We'll generate the first query when we call "subject", but won't
    # need another query
    specify { queries_for { subject.value_of(:id) }.should have(1).query }

    # We'll need to run our own query for the attributes
    specify { queries_for { subject.value_of(:first_name) }.should have(2).queries }

    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Person.where(:id => [1,50,100]).values_of(:id, :created_at, :extra_info) }
  end

  context 'with a loaded scope, an alternate primary key, and missing attributes' do
    subject do
      Widget.select(:widget_id).where(:widget_id => [1,50,100]).tap do |relation|
        relation.all
      end
    end

    # We'll generate the first query when we call "subject", but won't
    # need another query
    specify { queries_for { subject.value_of(:id) }.should have(1).query }
    specify { queries_for { subject.value_of(:widget_id) }.should have(1).query }

    # We'll need to run our own query for the attributes
    specify { queries_for { subject.value_of :name }.should have(2).queries }

    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Widget.where(:widget_id => [1,50,100]).values_of(:id, :created_at, :extra_info) }
  end

  context 'with a scope and multiple keys' do
    subject { Person.where(:id => [1,50,100]).values_of(:last_name, :id, :extra_info) }
    it { should have(3).elements }
    it { should eq [1,50,100].map {|n| ["Number#{n}", n, {:a_key => "Value Number #{n}"}]}}
  end

  context 'with an association' do
    subject { Person.first.widgets.value_of :id }
    it { should have(10).elements }
    it { should eq Person.first.widgets.map(&:id) }
  end

end
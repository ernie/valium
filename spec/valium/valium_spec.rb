require 'spec_helper'

describe Valium do

  context 'with a symbol' do
    subject { Person.value_of :id }
    it { should have(100).ids }
    it { should eq((1..100).to_a) }
  end

  context 'with a symbol calling hash_value_of' do
    subject { Person.hash_value_of :id }
    it { should have(100).hashes }
    it { should eq((1..100).to_a.map{|i| {'id' => i }}) }
  end

  context 'with a symbol and explicit as_hash option' do
    subject { Person.value_of :id, :as_hash => true  }
    it { should have(100).hashes }
    it { should eq((1..100).to_a.map{|i| {'id' => i }}) }
  end

  context 'with a string' do
    subject { Person.value_of 'id' }
    it { should have(100).ids }
    it { should eq((1..100).to_a) }
  end

  context 'with a symbol calling hash_value_of' do
    subject { Person.hash_value_of 'id' }
    it { should have(100).hashes }
    it { should eq((1..100).to_a.map{|i| {'id' => i }}) }
  end

  context 'with a string and explicit as_hash option' do
    subject { Person.value_of 'id', :as_hash => true  }
    it { should have(100).hashes }
    it { should eq((1..100).to_a.map{|i| {'id' => i }}) }
  end

  context 'with multiple values' do
    subject { Person.values_of :id, :last_name }
    it { should have(100).elements }
    it { should eq((1..100).map {|n| [n, "Number#{n}"]})}
  end

  context 'with multiple values calling hash_values_of' do
    subject { Person.hash_values_of :id, :last_name }
    it { should have(100).hashes }
    it { should eq((1..100).map {|n| { 'id' => n, 'last_name' => "Number#{n}"} })}
  end

  context 'with a datetime column' do
    subject { Person.value_of :created_at }
    it { should have(100).datetimes }
    it { should be_all {|d| Time === d}}
  end

  context 'with a datetime column calling hash_value_of' do
    subject { Person.hash_value_of :created_at }
    it { should have(100).hashes }
    it { should be_all {|h| Time === h['created_at']}}
  end

  context 'with a serialized column' do
    subject { Person.value_of :extra_info }
    it { should have(100).hashes }
    it { should eq 1.upto(100).map {|n| {:a_key => "Value Number #{n}"} }}
  end

  context 'with a serialized column calling hash_value_of' do
    subject { Person.hash_value_of :extra_info }
    it { should have(100).hashes }
    it { should eq 1.upto(100).map {|n| {'extra_info' => {:a_key => "Value Number #{n}"}} }}
  end

  context 'with an alternate primary key and an :id select' do
    subject { Widget.value_of :id }
    it { should have(100).ids }
    it { should eq((1..100).to_a)}
  end

  context 'with an alternate primary key and an :id select calling hash_value_of' do
    subject { Widget.hash_value_of :id }
    it { should have(100).hashes }
    it { should eq((1..100).to_a.map{|i| {'widget_id' => i }}) }
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

  context 'with a scope calling hash_value_of' do
    subject { Person.where(:id => [1,50,100]).hash_value_of :last_name }
    it { should have(3).hashes }
    it { should eq [ {'last_name'=>'Number1'}, {'last_name'=>'Number50'}, {'last_name'=>'Number100'}] }
  end

  context 'with a scope and value_of syntax' do
    subject { Person.where(:id => [1,50,100]).value_of :id }
    it { should have(3).ids }
    it { should eq [1,50,100] }
  end

  context 'with a scope and hash_value_of syntax' do
    subject { Person.where(:id => [1,50,100]).hash_value_of :id }
    it { should have(3).hashes }
    it { should eq [ {'id'=>1}, {'id'=>50},{'id'=>100} ] }
  end

  context 'with a scope, an alternate primary key, and an :id select' do
    subject {Widget.where(:widget_id => [1,50,100]).value_of :id }
    it { should have(3).ids }
    it { should eq [1,50,100]}
  end

  context 'with a scope, an alternate primary key, and an :id select calling hash_value_of' do
    subject {Widget.where(:widget_id => [1,50,100]).hash_value_of :id }
    it { should have(3).hashes }
    it { should eq [{'widget_id'=>1},{'widget_id'=>50},{'widget_id'=>100}]}
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
    specify { queries_for { subject.hash_value_of :id }.should have(1).query }

    specify { subject.values_of(:id).
              should eq [1,50,100] }
    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Person.where(:id => [1,50,100]).values_of(:id, :created_at, :extra_info) }


    specify { subject.hash_values_of(:id).
              should eq [{'id'=>1},{'id'=>50},{'id'=>100}] }
    specify { subject.hash_values_of(:id, :created_at, :extra_info).
              should eq Person.where(:id => [1,50,100]).hash_values_of(:id, :created_at, :extra_info) }
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
    specify { queries_for { subject.hash_value_of :id }.should have(1).query }

    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Widget.where(:widget_id => [1,50,100]).values_of(:id, :created_at, :extra_info) }
    specify { subject.hash_value_of(:id, :created_at, :extra_info).
              should eq Widget.where(:widget_id => [1,50,100]).hash_values_of(:id, :created_at, :extra_info) }
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
    specify { queries_for { subject.hash_value_of(:id) }.should have(1).query }

    # We'll need to run our own query for the attributes
    specify { queries_for { subject.value_of(:first_name) }.should have(2).queries }
    specify { queries_for { subject.hash_value_of(:first_name) }.should have(2).queries }

    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Person.where(:id => [1,50,100]).values_of(:id, :created_at, :extra_info) }
    specify { subject.hash_values_of(:id, :created_at, :extra_info).
              should eq Person.where(:id => [1,50,100]).hash_values_of(:id, :created_at, :extra_info) }
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
    specify { queries_for { subject.hash_value_of(:id) }.should have(1).query }
    specify { queries_for { subject.hash_value_of(:widget_id) }.should have(1).query }

    # We'll need to run our own query for the attributes
    specify { queries_for { subject.value_of :name }.should have(2).queries }
    specify { queries_for { subject.hash_value_of :name }.should have(2).queries }

    specify { subject.values_of(:id, :created_at, :extra_info).
              should eq Widget.where(:widget_id => [1,50,100]).values_of(:id, :created_at, :extra_info) }
    specify { subject.hash_values_of(:id, :created_at, :extra_info).
              should eq Widget.where(:widget_id => [1,50,100]).hash_values_of(:id, :created_at, :extra_info) }
  end

  context 'with a scope and multiple keys' do
    subject { Person.where(:id => [1,50,100]).values_of(:last_name, :id, :extra_info) }
    it { should have(3).elements }
    it { should eq [1,50,100].map {|n| ["Number#{n}", n, {:a_key => "Value Number #{n}"}]}}
  end

  context 'with a scope and multiple keys calling hash_values_of' do
    subject { Person.where(:id => [1,50,100]).hash_values_of(:last_name, :id, :extra_info) }
    it { should have(3).hashes }
    it { should eq [1,50,100].map {|n| {'last_name'=>"Number#{n}", 'id'=>n, 'extra_info' => {:a_key => "Value Number #{n}"}}}}
  end

  context 'with an association' do
    subject { Person.first.widgets.value_of :id }
    it { should have(10).elements }
    it { should eq Person.first.widgets.map(&:id) }
  end

  context 'with an association, calling hash_value_of' do
    subject { Person.first.widgets.hash_value_of :id }
    it { should have(10).hashes }
    it { should eq Person.first.widgets.map { |w| { 'widget_id' => w.id } } }
  end
  
  context 'with an association after call #collection= for that association' do
    subject do
      Person.new do |person|
        person.widgets = Widget.limit(10)
      end
    end
    
    specify { subject.widgets.value_of(:id).should == Widget.limit(10).value_of(:id) }
    specify { subject.widgets.hash_value_of(:id).should == Widget.limit(10).hash_value_of(:id) }
  end

end

require 'spec_helper'

describe Valium do

  context 'with a symbol key' do
    subject { Person[:id] }
    it { should have(100).ids }
    it { should eq((1..100).to_a) }
  end

  context 'with a string key' do
    subject { Person['id'] }
    it { should have(100).ids }
    it { should eq((1..100).to_a) }
  end

  context 'with multiple keys' do
    subject { Person[:id, :last_name] }
    it { should have(100).elements }
    it { should eq((1..100).map {|n| [n, "Number#{n}"]})}
  end

  context 'with a datetime column' do
    subject { Person[:created_at] }
    it { should have(100).datetimes }
    it { should be_all {|d| Time === d}}
  end

  context 'with a serialized column' do
    subject { Person[:extra_info] }
    it { should have(100).hashes }
    it { should eq 1.upto(100).map {|n| {:a_key => "Value Number #{n}"} }}
  end

  context 'with an alternate primary key and an :id select' do
    subject { Widget[:id] }
    it { should have(100).ids }
    it { should eq (1..100).to_a}
  end

  context 'with an alternate primary key and an alternate primary key select' do
    subject { Widget[:widget_id] }
    it { should have(100).ids }
    it { should eq (1..100).to_a}
  end

  context 'with a scope' do
    subject { Person.where(:id => [1,50,100])[:last_name] }
    it { should have(3).last_names }
    it { should eq ['Number1', 'Number50', 'Number100'] }
  end

  context 'with a scope, an alternate primary key, and an :id select' do
    subject {Widget.where(:widget_id => [1,50,100])[:id] }
    it { should have(3).ids }
    it { should eq [1,50,100]}
  end

  context 'with a scope, an alternate primary key, and an alternate primary key select' do
    subject { Widget.where(:widget_id => [1,50,100])[:widget_id] }
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
    specify { queries_for { subject[:id] }.should have(1).query }

    specify { subject[:id, :created_at, :extra_info].
              should eq Person.where(:id => [1,50,100])[:id, :created_at, :extra_info] }
  end

  context 'with a loaded scope, an alternate primary key, and an :id select' do
    subject do
      Widget.where(:widget_id => [1,50,100]).tap do |relation|
        relation.all
      end
    end

    # We'll generate the first query when we call "subject", but won't
    # need another query
    specify { queries_for { subject[:id] }.should have(1).query }

    specify { subject[:id, :created_at, :extra_info].
              should eq Widget.where(:widget_id => [1,50,100])[:id, :created_at, :extra_info] }
  end

  context 'with a loaded scope but missing attributes' do
    subject do
      Person.select(:id).where(:id => [1,50,100]).tap do |relation|
        relation.all
      end
    end

    # We'll generate the first query when we call "subject", but won't
    # need another query
    specify { queries_for { subject[:id] }.should have(1).query }

    # We'll need to run our own query for the attributes
    specify { queries_for { subject[:first_name] }.should have(2).queries }

    specify { subject[:id, :created_at, :extra_info].
              should eq Person.where(:id => [1,50,100])[:id, :created_at, :extra_info] }
  end

  context 'with a loaded scope, an alternate primary key, and missing attributes' do
    subject do
      Widget.select(:widget_id).where(:widget_id => [1,50,100]).tap do |relation|
        relation.all
      end
    end

    # We'll generate the first query when we call "subject", but won't
    # need another query
    specify { queries_for { subject[:id] }.should have(1).query }
    specify { queries_for { subject[:widget_id] }.should have(1).query }

    # We'll need to run our own query for the attributes
    specify { queries_for { subject[:name] }.should have(2).queries }

    specify { subject[:id, :created_at, :extra_info].
              should eq Widget.where(:widget_id => [1,50,100])[:id, :created_at, :extra_info] }
  end

  context 'with a scope and multiple keys' do
    subject { Person.where(:id => [1,50,100])[:last_name, :id, :extra_info] }
    it { should have(3).elements }
    it { should eq [1,50,100].map {|n| ["Number#{n}", n, {:a_key => "Value Number #{n}"}]}}
  end

  context 'with a relation array index' do
    subject { Person.where(:id => [1,50,100])[1] }
    it { should eq Person.find(50) }
  end

  context 'with a relation array start and length' do
    subject { Person.where(:id => 1..20)[10,3] }
    it { should have(3).people }
    it { should eq Person.offset(10).limit(3) }
  end

  context 'with a relation array range' do
    subject { Person.where(:id => 1..20)[0..9] }
    it { should have(10).people }
    it { should eq Person.first(10) }
  end

end
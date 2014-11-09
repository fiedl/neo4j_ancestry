require 'spec_helper'

describe Neo4jAncestry::Link do
  subject { @link ||= Neo4jAncestry::Link.new }
  
  it { should respond_to :parent }
  it { should respond_to :child }

end
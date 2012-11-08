require 'helper'

describe :label do

  subjectify_actor(:label)

  it 'has the label behavior' do
    behaviors = subject.instance_variable_get('@behaviors')
    behaviors.should include(:label)
  end
end

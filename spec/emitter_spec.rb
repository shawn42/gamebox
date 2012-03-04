require 'helper'

describe Emitter do
  subject { create_actor :emitter, {}, false }

  it 'should be' do
    subject.should be
  end

  it 'should add a timer for spawning particle actors' # do
    # subject.configure
  # end

end

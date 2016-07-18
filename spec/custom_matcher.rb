require 'rspec/expectations'

RSpec::Matchers.define :have_output do |text|
  match do |process|
    x=process.get(text)
    # binding.pry unless $__binding
    expect(x).to include(text)
  end

  failure_message do |process|
    "expected that \"#{process.last_get_return}\" would contains: #{text}"
  end
end

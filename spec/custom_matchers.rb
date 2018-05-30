require 'rspec/expectations'

RSpec::Matchers.define :have_output do |text|
  match do |process|
    expect(process.get(text)).to include(text)
  end

  failure_message do |process|
    "expected that \"#{process.last_get_return}\" would contains: #{text}"
  end
end

RSpec::Matchers.define :have_output_in do |text, second|
  match do |process|
    expect(process.get(text, max_wait: second)).to include(text)
  end

  failure_message do |process|
    "expected that \"#{process.last_get_return}\" would contains: #{text} in #{second}s"
  end
end

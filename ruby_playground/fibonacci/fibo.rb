# frozen_string_literal: true
# typed: true

def fibo(count) # rubocop:disable Metrics/MethodLength
  ret = []
  (0..count - 1).each do |i|
    if i.zero?
      ret.push(0)
    elsif i == 1
      ret.push(1)
    else
      ret.push(ret[i - 2] + ret[i - 1])
    end
  end

  ret
end

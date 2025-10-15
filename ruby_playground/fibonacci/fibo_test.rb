# frozen_string_literal: true
# typed: false

require_relative 'fibo'

RSpec.describe '#fibo' do
  it 'returns 8 first fibonacci numbers' do
    expect(fibo(8)).to eq([0, 1, 1, 2, 3, 5, 8, 13])
  end
end

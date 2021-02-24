# frozen_string_literal: true

class Transaction
  attr_reader :price, :amount
  attr_accessor :fake

  def initialize(price:, amount:, fake: false)
    @price = price
    @amount = amount
    @fake = fake
  end

  class << self
    def from_hash(hash)
      new(**hash.slice(:price, :amount, :fake))
    end
  end

  def fake?
    @fake
  end

  def return_percentage(market_price)
    ((market_price.to_f / price.to_f) - 1) * 100
  end

  def to_h
    { price:  price, amount: amount, fake: fake }
  end
end

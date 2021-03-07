# frozen_string_literal: true

class TransactionSet
  attr_reader :ticker, :transactions

  def initialize(ticker)
    @ticker = ticker
    @transactions = []
  end

  class << self
    def from_hash(hash)
      ticker       = (hash[:currency_type] || hash[:ticker] || :not_specified).to_sym
      transactions = hash.fetch(:transactions, [])

      new(ticker).tap do |ts|
        transactions.each do |t|
          ts.add_transaction(**t.slice(:price, :amount, :fake))
        end
      end
    end
  end

  def add_transaction(price:, amount:, fake: false)
    transactions.push Transaction.new(price: price, amount: amount, fake: fake)
  end

  def remove_fakes
    transactions.delete_if &:fake?
  end

  def buy_price
    total_spent / total_quantity
  end

  def return_percentage(market_price)
    "#{(transactions.sum {|t| t.return_percentage(market_price) } / transactions.size).round(2)}%"
  end

  def sell_targets
    TARGET_PERCENTAGES.map do |p|
      p_str = "#{(p * 100 - 100).round(2)}%"
      price = (buy_price * p).round(buy_price > 1.0 ? 2 : 6)
      { p_str => price }
    end
  end

  def total_spent
    transactions.sum {|t| t.price * t.amount }
  end

  def total_quantity
    transactions.sum(&:amount)
  end

  def to_h
    { ticker: ticker, transactions: transactions.map(&:to_h) }
  end

  alias sts sell_targets
  alias tq  total_quantity
  alias ts  total_spent
end

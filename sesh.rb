#!/usr/bin/env ruby
$LOAD_PATH.unshift Dir.pwd

SAVEFILE_DIR = './saves'

require 'transactions'
require 'json'
require 'pry'

$start_time = Time.now
$sets = []

def new_ts(currency_type='whatever, man')
  TransactionSet.new(currency_type).tap do |ts|
    $sets.push(ts)
  end
end

def save_sesh(force_new_filename: false)
  Dir.mkdir(SAVEFILE_DIR) unless Dir.exist?(SAVEFILE_DIR)

  time      = (force_new_filename ? Time.now : $start_time).to_i
  filename  = "sesh_#{time}"
  file_path = File.join(SAVEFILE_DIR, filename)
  content   = JSON.pretty_generate({start_time: time, sets: $sets.map(&:to_h)})

  File.write(file_path, content)
end

def load_last_sesh
  saves = Dir[File.join(File.expand_path(SAVEFILE_DIR), '*')]
  return "No saves in #{SAVEFILE_DIR} to load :(" if saves.empty?

  save_path = saves.sort.last
  from_json = JSON.parse(File.read(save_path), symbolize_names: true)

  $start_time = Time.at(from_json[:start_time])
  $sets = from_json[:sets].map {|ts_hash| TransactionSet.from_hash(ts_hash) }
end

binding.pry
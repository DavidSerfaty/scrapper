require 'bundler'
require "csv"
Bundler.require


$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper'


Scrapper.new.perform


# binding.pry

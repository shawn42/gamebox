#!/usr/bin/env ruby

$: << File.join(File.dirname($0),"..","config")
require 'environment'

GameboxApp.run ARGV, ENV

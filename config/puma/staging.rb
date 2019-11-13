#!/usr/bin/env puma

_load_from File.expand_path("../../puma.rb", __FILE__)

environment "staging"

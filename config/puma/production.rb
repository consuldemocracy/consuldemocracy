#!/usr/bin/env puma

_load_from File.expand_path("../k8s.rb", __FILE__)

environment "production"

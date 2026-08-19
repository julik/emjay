# frozen_string_literal: true

require_relative "lib/emjay/version"

Gem::Specification.new do |spec|
  spec.name = "emjay"
  spec.version = Emjay::VERSION
  spec.authors = ["Julik Tarkhanov"]
  spec.email = ["me@julik.nl"]

  spec.summary = "Pure-Ruby MJML renderer"
  spec.description = "Converts MJML email markup to responsive HTML — no Node.js, no native extensions, no shelling out."
  spec.homepage = "https://github.com/julik/emjay"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  spec.files = Dir["lib/**/*.rb", "LICENSE", "README.md", "llms.txt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", ">= 1.12"
  spec.add_dependency "premailer"
end

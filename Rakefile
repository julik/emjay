# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: [:test, :standard]

namespace :fixtures do
  desc "Regenerate expected HTML files from .mjml fixtures using upstream JS MJML"
  task :regenerate do
    require "json"
    require "open3"

    mjml_dir = File.expand_path("tmp/mjml", __dir__)
    fixtures_dir = File.expand_path("test/fixtures", __dir__)

    mjml_files = Dir.glob("#{fixtures_dir}/**/*.mjml")

    if mjml_files.empty?
      puts "No .mjml fixtures found in #{fixtures_dir}"
      next
    end

    # Build a single Node script that processes all fixtures
    script = <<~JS
      const mjml2html = require('mjml');
      const fs = require('fs');
      (async () => {
        const files = JSON.parse(process.argv[1]);
        for (const f of files) {
          const input = fs.readFileSync(f.input, 'utf8');
          const result = await mjml2html(input, { minify: false, beautify: false });
          fs.writeFileSync(f.output, result.html, 'utf8');
          console.log('  ' + f.output);
        }
      })();
    JS

    files_arg = mjml_files.map { |f|
      {
        input: f,
        output: f.sub(/\.mjml$/, ".expected.html")
      }
    }.to_json

    puts "Regenerating #{mjml_files.length} fixture(s)..."

    stdout, stderr, status = Open3.capture3(
      "node", "-e", script, files_arg,
      chdir: mjml_dir
    )

    puts stdout unless stdout.empty?
    warn stderr unless stderr.empty?

    unless status.success?
      abort "Failed to regenerate fixtures (exit #{status.exitstatus})"
    end

    puts "Done."
  end
end

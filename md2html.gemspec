lib = File.expand_path( '../lib', __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include?( lib )
require 'md2html'

Gem::Specification.new() do |spec|
	spec.name = Md2html::NAME;
	spec.summary = Md2html::SUMMARY;
	spec.version = Md2html::VERSION;
	spec.date = Md2html::DATE;
	spec.license = Md2html::LICENSE;

	spec.authors = Md2html::AUTHORS;
	spec.email = Md2html::EMAIL;
	spec.homepage = Md2html::HOMEPAGE;

	spec.files = ['lib/md2html.rb'];
	spec.executables = ['md2html'];

	spec.add_runtime_dependency( 'etc', '~> 1.0.1' );
	spec.add_runtime_dependency( 'pandoc-ruby', '~> 2.0.2' );
	spec.add_runtime_dependency( 'redcarpet', '~> 3.5.0' );
	spec.add_runtime_dependency( 'kramdown', '~> 2.1.0' );
	spec.add_runtime_dependency( 'maruku', '~> 0.7.3' );
    spec.add_runtime_dependency( 'rdiscount', '~> 2.2.0.1' );
	spec.add_runtime_dependency( 'nokogiri', '~> 1.10.4' );
	spec.add_runtime_dependency( 'htmlbeautifier', '~> 1.3.1' );
end


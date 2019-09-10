require 'etc'
require 'yaml'
require 'pandoc-ruby'
require 'redcarpet'
require 'kramdown'
require 'maruku'
require 'rdiscount'
require 'nokogiri'
require 'htmlbeautifier'

# SEE ALSO: https://www.sitepoint.com/markdown-processing-ruby/

module Md2html

    # -------------------------------------------------------------------
    # gemspec
  NAME = 'md2html';
  SUMMARY = 'Markdown to HTML converter';
  VERSION = '0.0.0';
  DATE = '2019-09-05';
  LICENSE = 'CC-BY-3.0'

  AUTHORS = ['Stephan R. Kuberski'];
  EMAIL = 'kuberski@uni-potsdam.de';
  HOMEPAGE = 'http://www.ling.uni-potsdam.de/~kuberski/';

    # -------------------------------------------------------------------
    # conversion
  YAML_FRONT_MATTER = /\A---(.|\n)*?---/;

  def self.convert()

      # command line arguments
    mdfile = ARGV[0];

      # default meta data
    _title = mdfile;
    _author = Etc.getlogin();
    _date = Time.now().strftime("%Y-%m-%d");

    _template_dir = '/home/kuberski/code/md2html/tpl'
    _template = 'pandoc'; # [plain, pandoc, github]

    _html_dir = '.';
    _html_base = 1;
    _html_header = '';
    _html_footer = '';

    _md_header = '';
    _md_footer = '';

    _renderer = 'pandoc';

      # read input file (markdown)
    mdfull = File.read( mdfile );

    mdfront = mdfull[YAML_FRONT_MATTER] || ""; # separate front matter
    mdmain = mdfull.gsub( YAML_FRONT_MATTER, '' );

      # process front matter (yaml)
    yaml = YAML.load( mdfront, fallback: Hash.new() ) || Hash.new();

    _title = yaml['title'] if yaml.has_key?( 'title' ); # user-defined values
    _author = yaml['author'] if yaml.has_key?( 'author' );
    _date = yaml['date'] if yaml.has_key?( 'date' );

    _template_dir = yaml['template_dir'] if yaml.has_key?( 'template_dir' );
    _template = yaml['template'] if yaml.has_key?( 'template' );

    _html_dir = yaml['html_dir'] if yaml.has_key?( 'html_dir' );
    _html_base = yaml['html_base'] if yaml.has_key?( 'html_base' );
    _html_header = yaml['html_header'] if yaml.has_key?( 'html_header' );
    _html_footer = yaml['html_footer'] if yaml.has_key?( 'html_footer' );

    _md_header = yaml['md_header'] if yaml.has_key?( 'md_header' );
    _md_footer = yaml['md_footer'] if yaml.has_key?( 'md_footer' );

    _renderer = yaml['renderer'] if yaml.has_key?( 'renderer' );

    case _template # template-specific overrides
    when 'ling-srk'
      _html_dir = 'html' unless yaml.has_key?( 'html_dir' );
      _html_base = 2 unless yaml.has_key?( 'html_base' );
    end

      # verify front matter
    raise 'invalid value: _html_base' if _html_base < 1 || _html_base > 6;

    raise 'invalid value: _renderer' unless ['pandoc', 'redcarpet', 'kramdown', 'maruku', 'rdiscount'].include?( _renderer );

      # process main matter (html)
    case _renderer
    when 'pandoc'
      md = PandocRuby.new( mdmain, :mathjax, :f => :markdown, :to => :html5 );
      html = md.convert();
    when 'redcarpet'
      opts = {no_intra_emphasis: true, tables: true, fenced_code_blocks: true};
      md = Redcarpet::Markdown.new( Redcarpet::Render::HTML, opts );
      html = md.render( mdmain );
    when 'kramdown'
      md = Kramdown::Document.new( mdmain );
      html = md.to_html();
    when 'maruku'
      md = Maruku.new( mdmain );
      html = md.to_html();
    when 'rdiscount'
      md = RDiscount.new( mdmain, :smart, :footnotes );
      html = md.to_html();
    end

      # postprocess main matter (html)
    ng = Nokogiri::HTML::DocumentFragment.parse( html );

    ng.xpath( './*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5 or self::h6]' ).each do |n| # shift header levels
      m = [6-n.name.scan( /\d+/ ).first().to_i(), _html_base-1].min();
      m.times { n.name = n.name.succ(); };
    end

    ng.children.each do |n| # remove empty tags
      # n.remove unless n.child
      n.remove if n.content.strip.empty?();
    end

    html = ng.to_xhtml();

      # process template (html)
    tplfile = "#{_template_dir}/#{_template}.html"
    tpl = File.read( tplfile );

    tpl.gsub!( '{{title}}', _title );
    tpl.gsub!( '{{date}}', _date );
    tpl.gsub!( '{{main}}', html.to_s() );

      # write html
    tpl = HtmlBeautifier.beautify( tpl, indent: "\t" );

    htmlfile = "#{_html_dir}/#{File.basename( mdfile, '.*' )}.html";
    File.write( htmlfile, tpl );

  end

    # -------------------------------------------------------------------
    # helpers
  private

  def self.wrap_article( ng )
    ng.add_child( '<div class="article">' ).first();
  end

end


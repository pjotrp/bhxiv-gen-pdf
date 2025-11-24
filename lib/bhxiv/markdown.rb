# Methods to parse the markdown header

require 'yaml'

class MarkdownError < StandardError
end

def md_parser(filename)
  raise MarkdownError, "Markdown file '#{filename}' does not exist" unless File.exist?(filename)

  begin
    content = File.read(filename)
    YAML.safe_load(content, aliases: true)
  rescue Psych::SyntaxError => e
    raise MarkdownError, "Invalid YAML syntax in #{filename}: #{e.message}"
  rescue => e
    raise MarkdownError, "Error reading #{filename}: #{e.message}"
  end
end

def meta_expand(header)
  raise MarkdownError, "biohackathon_name field is missing" unless header["biohackathon_name"]
  raise MarkdownError, "biohackathon_url field is missing" unless header["biohackathon_url"]
  raise MarkdownError, "biohackathon_location field is missing" unless header["biohackathon_location"]
  raise MarkdownError, "git_url field is missing" unless header["git_url"]
  header
end

def md_meta_checker(meta)
  raise MarkdownError, "title field is missing" unless meta["title"]
  raise MarkdownError, "tags field is missing" unless meta["tags"]
  raise MarkdownError, "authors field is missing" unless meta["authors"]
  raise MarkdownError, "not enough authors (2 minimum)" if meta["authors"].length < 2
  raise MarkdownError, "group field is missing" unless meta["group"]
  raise MarkdownError, "date field is missing" unless meta["date"]
  raise MarkdownError, "bibliography field is missing" unless meta["cito-bibliography"] || meta["bibliography"]
  raise MarkdownError, "event field is missing" unless meta["event"]
  raise MarkdownError, "authors_short field is missing" unless meta["authors_short"]
  meta
end

def md_checker(filename)
  header = md_parser(filename)
  md_meta_checker(header)
end

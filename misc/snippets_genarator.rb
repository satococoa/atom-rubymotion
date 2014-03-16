require 'bundler/setup'
Bundler.require
require 'pp'

DATADIR = '/Library/RubyMotion/data'

BRIDGE_SUPPORT_FILES = {
  ios: Dir.glob(DATADIR + '/ios/7.1/BridgeSupport/*.bridgesupport'),
  osx: Dir.glob(DATADIR + '/osx/10.9/BridgeSupport/*.bridgesupport')
}

def generate_snippet(name, prefix, body)
  <<-EOS
  '#{name}':
    'prefix': '#{prefix}'
    'body': '#{body.gsub(/^k/, 'K')}'
  EOS
end

def process_node(node)
  snippets = []
  case node.name
  when 'struct'
    # do nothing.
  when 'cftype'
    # do nothing.
  when 'constant'
    snippets << generate_snippet("#{node[:name]} (#{node[:declared_type]})", node[:name], node[:name])
  when 'enum'
    snippets << generate_snippet("#{node[:name]} (#{node[:value]})", node[:name], node[:name])
  when 'function'
    name = node[:name]
    trigger = node[:name]
    args = node.xpath('./arg').map.with_index {|n, i|
      "${#{i+1}:#{n[:declared_type]} #{n[:name]}}"
    }
    body = "#{name}(#{args.join(', ')})"
    snippets << generate_snippet(name, trigger, body)
  when 'class', 'informal_protocol'
    node.xpath('./method').each do |method_node|
      if method_node[:class_method] == 'true'
        name = "#{node[:name]}.#{method_node[:selector]}"
      else
        name = method_node[:selector]
      end
      trigger = method_node[:selector]
      selector_tokens = name.split(':')
      args = method_node.xpath('./arg').map.with_index {|n, i|
        arg = ''
        arg << "#{selector_tokens[i]}:" if i > 0
        arg << "${#{i+1}:#{n[:declared_type]} #{n[:name]}}"
      }
      body = "#{selector_tokens.first}(#{args.join(', ')})"
      snippets << generate_snippet(name, trigger, body)
    end
  when 'depends_on'
    # do nothing.
  when 'opaque'
    # do nothing.
  when 'string_constant'
    snippets << generate_snippet("#{node[:name]} (#{node[:value]})", node[:name], node[:name])
  when 'function_alias'
    snippets << generate_snippet("#{node[:name]} (#{node[:original]})", node[:name], node[:name])
  else
    STDERR.puts "\e[31mUnknown node: #{node.name}\e[0m"
  end
  snippets
end

BRIDGE_SUPPORT_FILES[:ios].each do |file|
  filename = File.basename(file, '.bridgesupport').downcase
  File.open("../snippets/cocoatouch-#{filename}.cson", 'w') {|f|
    f.puts "'.source.rubymotion':"
    doc = Nokogiri::XML(File.read(file))
    doc.xpath('/signatures/*').each do |node|
      f.puts process_node(node)
    end
  }
end

# BRIDGE_SUPPORT_FILES[:osx].each do |file|
#   filename = File.basename(file, '.bridgesupport').downcase
#   File.open("../snippets/cocoa-#{filename}.cson", 'w') {|f|
#     f.puts "'.source.rubymotion':"
#     doc = Nokogiri::XML(File.read(file))
#     doc.xpath('/signatures/*').each do |node|
#       f.puts process_node(node)
#     end
#   }
# end

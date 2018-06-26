require 'open3'
require_relative 'process_path'

module UnZip
  include ProcessPath

  def initialize
    super
    @not_submitted_list = []
    @unzip_error_list = []
  end

  # 全ファイルを再帰的に探索
  def unzip_traverse(path)
    p path
    if File.directory?(path)
      if Dir.empty?(path) && File.basename(path) == "提出物の添付"
        @not_submitted_list << extract_id_and_name(path)
      else
        Dir.each_child(path) { |name| unzip_traverse(path + "/" + name) }
      end
    elsif File.extname(path) == ".zip"
      expand_zip(path)
    end
  end

  # zipを展開
  def expand_zip(path)
    expanded_dir = path.gsub(/\.zip/, "")
    # すでに展開してあるか判定
    unless Dir.exist?(expanded_dir)
      o, e, s = Open3.capture3("unzip '#{path}' -d '#{expanded_dir}'")
      @unzip_error_list << extract_id_and_name(path) unless e.empty?
    end
  end
end

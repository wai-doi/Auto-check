require 'fileutils'
require_relative 'directory'
require_relative 'process_path'

module Compile
  include Directory
  include ProcessPath

  def initialize
    super
    @cannot_compile_list = []
    @compile_files = Dir.glob("#{COMPILE_FILES_PATH}*").map {|path| File.basename(path) }
  end

  # 全ファイルを再帰的に探索
  def compile_traverse(path)
    p path

    # ディレクトリの場合さらに探索
    if File.directory?(path)
      Dir.each_child(path) { |name| compile_traverse(path + "/" + name) }

    # 提出されたCファイルの場合はコンパイル処理へ
    elsif File.extname(path) == ".c" && !@compile_files.member?(File.basename(path))
      processing_for_c(path)
    end
  end

  def processing_for_c(path)
    copy_need_files_for_compile(File.dirname(path))
    begin
      exe_file = compile(path)
      copy_file_to_work_dir(exe_file, path)
    rescue
      @cannot_compile_list << extract_id_and_name(path)
    end
  end

  # コンパイルに必要なファイル群を、ディレクトリにコピー
  def copy_need_files_for_compile(dir_path)
    need_files = Dir.glob("#{COMPILE_FILES_PATH}*")
    need_files.each { |file| FileUtils.cp(file, dir_path) }
  end

  # cファイルをコンパイルし実行ファイルを返す
  def compile(path)
    exe_file = path.gsub(/\.c/, "")
    sub_c_files = Dir.glob("#{COMPILE_FILES_PATH}/*.c")
      .map { |e| "'#{e}'" }
      .join(" ")
    compile_command = "gcc -o '#{exe_file}' '#{path}' #{sub_c_files}"
    puts compile_command
    system(compile_command)
    exe_file
  end

  def copy_file_to_work_dir(exe_file, path)
    id, name = extract_id_and_name(path)
    individual_dir = WORK_DIR + "#{id}-#{name}/"
    Dir.mkdir(individual_dir) unless Dir.exist?(individual_dir)
    FileUtils.cp([path, exe_file], individual_dir)
  end
end

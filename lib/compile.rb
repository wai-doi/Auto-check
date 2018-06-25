require_relative 'process_path'

module Compile
  include ProcessPath

  # あとで実行テストを行う用のディレクトリ
  WORK_DIR = "./work_dir/"

  # コンパイルに必要なファイル群
  # work_dirに入れておく
  NEED_FILES_FOR_COMPILE = %w(winlib.c winlib.h)

  def initialize
    super
    @cannot_compile_list = []
  end

  # 全ファイルを再帰的に探索
  def compile_traverse(path)
    p path
    if File.directory?(path)
      Dir.each_child(path) { |name| compile_traverse(path + "/" + name) }
    elsif File.extname(path) == ".c" && !NEED_FILES_FOR_COMPILE.member?(File.basename(path))
      processing_for_c(path)
    end
  end

  def processing_for_c(path)
    copy_need_files_for_compile(File.dirname(path))
    begin
      exe_file = compile(path)
      copy_exe_file_to_work_dir(exe_file, path)
    rescue
      @cannot_compile_list << extract_id_and_name(path)
    end
  end

  # コンパイルに必要なwinlibファイル群を、ディレクトリにコピー
  def copy_need_files_for_compile(dir_path)
    need_files = NEED_FILES_FOR_COMPILE.map { |file| WORK_DIR + file }
    need_files.each { |file| FileUtils.cp(file, dir_path) }
  end

  # cファイルをコンパイルし実行ファイルを返す
  def compile(path)
    exe_file = path.gsub(/\.c/, "")
    object_files = [WORK_DIR + "winlib.o"].join(" ")
    system("gcc -o '#{exe_file}' '#{path}' '#{object_files}'")
    exe_file
  end

  def copy_exe_file_to_work_dir(exe_file, path)
    id, name = extract_id_and_name(path)
    individual_dir = WORK_DIR + "#{id}-#{name}/"
    Dir.mkdir(individual_dir) unless Dir.exist?(individual_dir)
    FileUtils.cp(exe_file, individual_dir)
  end
end

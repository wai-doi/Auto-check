require 'fileutils'

class AutoCheckHomework
  # 先生とTAのID
  TEATURES_ID = %w(32115160 52034959 281743160 281843088)

  # あとで実行テストを行う用のディレクトリ
  WORK_DIR = "./work_dir/"

  # コンパイルに必要なファイル群
  # work_dirに入れておく
  NEED_FILES_FOR_COMPILE = %w(winlib.c winlib.h)

  def self.execute(kadai_dir)
    self.new.execute(kadai_dir)
  end

  def initialize
    @not_submitted_list= []
    @cannot_compile_list = []
  end

  def execute(kadai_dir)
    raise "#{kadai_dir}はありません" unless File.directory?(kadai_dir)

    # unzip
    unzip_traverse(kadai_dir)

    # compile
    compile_traverse(kadai_dir)

    # 先生とTAはリストから除く
    @not_submitted_list.reject! { |id, _| TEATURES_ID.member?(id) }
    display_data
  end

  private

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

  def extract_id_and_name(path)
    path.scan(/\/(\d+)\((.+),\)\//).first
  end

  # zipを展開
  def expand_zip(path)
    expanded_dir = path.gsub(/\.zip/, "")
    # すでに展開してあるか判定
    unless Dir.exist?(expanded_dir)
      system("unzip '#{path}' -d '#{expanded_dir}'")
    end
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

  def display_data
    puts
    puts "--- 未提出者リスト ---"
    puts @not_submitted_list.map { |item| item.join("\t") }
    puts @not_submitted_list.size

    puts "--- コンパイルエラー ---"
    puts @cannot_compile_list.map { |item| item.join("\t") }
    puts @cannot_compile_list.size
  end
end

AutoCheckHomework.execute(ARGV[0])

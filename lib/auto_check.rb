require 'fileutils'

class AutoCheckHomework
  # 先生とTAのID
  TEATURES_ID = %w(32115160 52034959 281743160 281843088)
  # あとで実行テストを行う用のディレクトリ
  WORK_DIR = "./work_dir/"

  @@not_submitted_students = []

  def self.execute(kadai_dir)
    self.new.execute(kadai_dir)
  end

  def execute(kadai_dir)
    raise unless File.directory?(kadai_dir)
    traverse(kadai_dir)
    # 先生とTAはリストから除く
    @@not_submitted_students.reject!{|id, _| TEATURES_ID.member?(id)}
    display_data
  end

  private

  # 全ファイルを再帰的に探索
  def traverse(path)
    p path
    if File.directory?(path)
      if Dir.empty?(path) && File.basename(path) == "提出物の添付"
        # 未提出者をリストに追加
        @@not_submitted_students << extract_id_and_name(path)
      else
        Dir.each_child(path) do |name|
          traverse(path + "/" + name)
        end
      end
    elsif File.extname(path) == ".zip"
      expand_zip(path)
    elsif File.extname(path) == ".c" && File.basename(path) != "winlib.c"
      copy_winlibs(File.dirname(path))
      exe_file = compile(path)
      copy_exe_file_to_WORK_DIR(exe_file, path)
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

  # コンパイルに必要なwinlibファイル群を、ディレクトリにコピー
  def copy_winlibs(dir_path)
    winlibs = ["winlib.h", "winlib.c"].map{|file| WORK_DIR + file}
    winlibs.each { |file| FileUtils.cp(file, dir_path) }
  end

  # cファイルをコンパイルし実行ファイルを返す
  def compile(path)
    exe_file = path.gsub(/\.c/, "")
    object_files = [WORK_DIR + "winlib.o"].join(" ")
    system("gcc -o '#{exe_file}' '#{path}' '#{object_files}'")
    exe_file
  end

  def copy_exe_file_to_WORK_DIR(exe_file, path)
    id, name = extract_id_and_name(path)
    individual_dir = WORK_DIR + "#{id}-#{name}/"
    Dir.mkdir(individual_dir) unless Dir.exist?(individual_dir)
    FileUtils.cp(exe_file, individual_dir)
  end

  def display_data
    puts "---未提出者リスト---"
    puts @@not_submitted_students.map{|item| item.join("\t")}
    puts @@not_submitted_students.size
  end
end

AutoCheckHomework.execute(ARGV[0])

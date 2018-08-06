module Directory
  # あとで実行テストを行う用のディレクトリ
  # ここに実行ファイルがコピーされる
  WORK_DIR = "./work_dir/"

  # コンパイルに必要なファイル群が入ったディレクトリ
  COMPILE_FILES_PATH = "./compile_files/"

  # 実行テストに必要なファイル群を入ったディレクトリ
  EXEUTION_FILES_DIR = "./execution_files/"
  
  def try_exist_dirs
    dirs = [WORK_DIR, COMPILE_FILES_PATH, EXEUTION_FILES_DIR]
    dirs.each do |dir|
      raise "#{dir}はありません" unless File.directory?(dir)
    end
  end
end

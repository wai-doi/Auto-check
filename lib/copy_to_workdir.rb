# 実行に必要なファイル、ディレクトリを各実行ディレクトリにコピーする

require 'fileutils'

WORK_DIR = "./work_dir/"

Dir.glob("#{WORK_DIR}*/").each do |to|
  ARGV.each do |from|
    FileUtils.cp_r(from, to)
  end
end

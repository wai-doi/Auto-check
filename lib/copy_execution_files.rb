require 'fileutils'
require_relative 'directory'

module CopyExecutionFiles
  include Directory

  def copy_execution_files
    Dir.glob("#{WORK_DIR}*/").each do |to|
      Dir.glob("#{EXEUTION_FILES_DIR}*").each do |from|
        FileUtils.cp_r(from, to)
      end
    end
  end
end

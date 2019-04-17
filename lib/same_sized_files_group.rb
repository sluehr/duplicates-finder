require 'digest'
require 'fileutils'
require_relative 'duplicate_files_group'
require_relative 'same_sized_files_group'

module Duplicates

  class SameSizedFilesGroup
    attr_accessor :files

    def initialize(files = [])
      @files = files
    end

    def add(file)
      @files.push(file)
    end

    def size
      @files.size
    end

    # returns an array of DuplicateFilesGroup
    def duplicates
      return [] if size < 2

      size == 2 ? resolve_by_content : resolve_by_digest
    end

    def ==(other)
      @files == other.files
    end


    private

    def resolve_by_content
      same = FileUtils.compare_file(@files.first.path, @files.last.path)
      same ? [DuplicateFilesGroup.new(@files)] : []
    end

    def resolve_by_digest
      group_by_digest.select {|values| values.size > 1}
    end

    def group_by_digest
      new_groups = Hash.new {|hash, key| hash[key] = DuplicateFilesGroup.new}

      @files.each do |file|
        digest = Digest::MD5.file(file.path).to_s
        new_groups[digest].add(file)
      end
      new_groups.values
    end
  end

end
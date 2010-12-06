#!/usr/bin/env ruby

require 'fileutils'

module PackIt
  
  class Packager
    @directory
    @first_branch
    @secord_branch

    def initialize(directory, first_branch, second_branch)
      @directory, @first_branch, @second_branch = directory, first_branch, second_branch
    end

    def run
      files = list_different_files_between_branches
      directories = list_directories_to_create(files)
      create_directories(directories)
      copy_files_to_destiny(files)
    end

    private

    def list_different_files_between_branches
      files = Array.new
      (%x[git diff --name-status #{@first_branch}..#{@second_branch}]).split("\n").each do |file|
        f = file.split("\t")
        files.push(f[1]) unless f[0].eql?("D")
      end
      files
    end
    
    def list_directories_to_create(files)
      directories = Array.new
      files.each{ |f| directories.push(File.dirname(f)) }
      directories
    end

    def create_directories(directories)
      directories.each{ |d| FileUtils.mkdir_p("#{@directory}/#{d}") unless d.eql?(".") }
    end

    def copy_files_to_destiny(files)
      files.each { |f| FileUtils.cp_r(f, "#{@directory}/#{f}") }
    end

  end
  
  class PreProcessor    
    def self.are_the_arguments_valid?(args)
      true unless args.empty? or args.size != 3
    end
    
    def self.is_the_git_installed?
      true if %x[git --version].include?("git version")
    end
    
    def self.is_a_git_repository?
      true if File.exists?(".git") && File.directory?(".git")
    end
  end

  def self.run(arguments)
    if not PreProcessor.are_the_arguments_valid?(arguments)
      puts "
            Pack It - Create a folder with the different files between two branches of git.
            
            Example: ./pack_it.rb package a_branch another_branch
            
            package => folder where the files are copied
            a_branch => first branch used in the comparison
            another_branch = second branch used in the comparison
            
            
            Developed by Rodrigo Lazoti (rodrigolazoti@gmail.com)
            http://www.rodrigolazoti.com.br
           "
           
    elsif not PreProcessor.is_the_git_installed?
      puts "
            You have nothing GIT client in this machine. 
            Please, install it!
           "

    elsif not PreProcessor.is_a_git_repository?
      puts "The current directory isn't a git repository."
      
    else
      packager = Packager.new(arguments[0], arguments[1], arguments[2])
      packager.run
    end
  end

end

PackIt::run(ARGV)
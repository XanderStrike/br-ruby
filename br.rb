#!/usr/bin/env ruby

def get_branches
  branches = `git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'`.split("\n")
  branches.map.with_index(1) do |branch, index|
    "#{index}. #{branch}"
  end
end

require 'io/console'

def display_picker(branches)
  puts "Select a branch to switch to:"
  index = 0
  search_mode = false
  search_query = ""

  loop do
    system("clear")
    filtered_branches = branches.select { |branch| branch.include?(search_query) }
    filtered_branches.each_with_index do |branch, i|
      if i == index
        puts "> #{branch}"
      else
        puts "  #{branch}"
      end
    end

    input = $stdin.getch
    case input
    when "\r"
      return branches.index(filtered_branches[index]) + 1
    when "\e[A", "k"
      index = (index - 1) % filtered_branches.size
    when "\e[B", "j"
      index = (index + 1) % filtered_branches.size
    when "/"
      print "Search: "
      search_query = gets.chomp
      index = 0
    end
  end
end

def switch_branch(branches, choice)
  if choice.between?(1, branches.size)
    branch_name = branches[choice - 1].split[1]
    system("git checkout #{branch_name}")
  else
    puts "Invalid choice"
  end
end

branches = get_branches
choice = display_picker(branches)
switch_branch(branches, choice)

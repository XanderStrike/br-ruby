#!/usr/bin/env ruby

def get_branches
  `git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'`.split("\n")
end

require 'io/console'

def display_picker(branches)
  search_mode = false
  search_query = ""

  puts "Use j/k or arrow keys to navigate, / to search, Enter to select, Esc or Ctrl+C to exit."
  index = 0
  search_mode = false
  search_query = ""

  loop do
    system("clear")
    filtered_branches = branches.select { |branch| branch.include?(search_query) }
    if search_mode
      puts "Search: #{search_query}"
    else
      puts "Use j/k or arrow keys to navigate, / to search, Enter to select, Esc or Ctrl+C to exit."
    end
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
      return branches.index(filtered_branches[index])
    when "\e[A", "k"
      index = (index - 1) % filtered_branches.size if !search_mode && !filtered_branches.empty?
    when "\e[B", "j"
      index = (index + 1) % filtered_branches.size if !search_mode && !filtered_branches.empty?
    when "/"
      search_mode = true
      search_query = ""
    when "\u007F" # Handle backspace
      search_query.chop! if search_mode
    when "\e", "\u0003" # Escape or Ctrl+C
      puts "Exiting without changing branch."
      exit
    else
      if search_mode
        if input == "\u007F" # Handle backspace
          search_query.chop!
        elsif input.match?(/^[a-zA-Z0-9]$/)
          search_query << input
        end
        index = 0
      end
    end
  end
end

def switch_branch(branches, choice)
  if choice.between?(0, branches.size - 1)
    branch_name = branches[choice].split.first
    system("git checkout #{branch_name}")
  else
    puts "Invalid choice"
  end
end

branches = get_branches
choice = display_picker(branches)
switch_branch(branches, choice)

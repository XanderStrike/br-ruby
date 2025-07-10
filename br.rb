#!/usr/bin/env ruby

def get_branches
  current_branch = `git rev-parse --abbrev-ref HEAD`.strip
  branches = `git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'`.split("\n")
  return branches, current_branch
end

def find_closest_branch(branches, query)
  query = query.downcase

  # Extract just the branch names for matching
  branch_names = branches.map { |branch| branch.split.first }

  # First try exact match
  exact_match = branch_names.find { |name| name.downcase == query }
  return branches[branch_names.index(exact_match)] if exact_match

  # Then try branches that start with the query
  starts_with = branch_names.select { |name| name.downcase.start_with?(query) }
  if starts_with.any?
    # Return the shortest match (most likely to be intended)
    best_match = starts_with.min_by(&:length)
    return branches[branch_names.index(best_match)]
  end

  # Finally try branches that contain the query
  contains = branch_names.select { |name| name.downcase.include?(query) }
  if contains.any?
    # Return the shortest match
    best_match = contains.min_by(&:length)
    return branches[branch_names.index(best_match)]
  end

  nil
end

require 'io/console'

def display_picker(branches, current_branch)
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
    start_index = [index - 5, 0].max
    end_index = [start_index + 10, filtered_branches.size].min
    visible_branches = filtered_branches[start_index...end_index]

    visible_branches.each_with_index do |branch, i|
      actual_index = start_index + i
      branch_name, time_ago = branch.split(' ', 2)
      branch_display = if branch_name == current_branch
                         "\e[32m#{branch_name}\e[0m" # Green for current branch
                       else
                         branch_name
                       end
      time_display = "\e[2m#{time_ago}\e[0m" # Dim the time
      if actual_index == index
        puts "> #{branch_display} #{time_display}"
      else
        puts "  #{branch_display} #{time_display}"
      end
    end

    input = $stdin.getch
    case input
    when "\r"
      return branches.index(filtered_branches[index])
    when "\e[A"
      index = (index - 1) % filtered_branches.size if !search_mode && !filtered_branches.empty?
    when "\e[B"
      index = (index + 1) % filtered_branches.size if !search_mode && !filtered_branches.empty?
    when "k"
      if search_mode
        search_query << "k"
        index = 0
      else
        index = (index - 1) % filtered_branches.size if !filtered_branches.empty?
      end
    when "j"
      if search_mode
        search_query << "j"
        index = 0
      else
        index = (index + 1) % filtered_branches.size if !filtered_branches.empty?
      end
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

def switch_branch_by_name(branch_line)
  branch_name = branch_line.split.first
  puts "Switching to branch: #{branch_name}"
  system("git checkout #{branch_name}")
end

branches, current_branch = get_branches

# Check if an argument was provided
if ARGV.length > 0
  query = ARGV[0]
  matching_branch = find_closest_branch(branches, query)

  if matching_branch
    switch_branch_by_name(matching_branch)
  else
    puts "No branch found matching '#{query}'"
    puts "Available branches:"
    branches.each do |branch|
      branch_name = branch.split.first
      puts "  #{branch_name}"
    end
    exit 1
  end
else
  # No argument provided, show interactive picker
  choice = display_picker(branches, current_branch)
  switch_branch(branches, choice)
end

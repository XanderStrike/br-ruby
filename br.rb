#!/usr/bin/env ruby

def get_branches
  branches = `git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'`.split("\n")
  branches.map.with_index(1) do |branch, index|
    "#{index}. #{branch}"
  end
end

def display_picker(branches)
  puts "Select a branch to switch to:"
  branches.each { |branch| puts branch }
  print "Enter the number of the branch: "
  choice = gets.to_i
  choice
end

def switch_branch(branches, choice)
  if choice.between?(1, branches.size)
    branch_name = branches[choice - 1].split.first
    system("git checkout #{branch_name}")
  else
    puts "Invalid choice"
  end
end

branches = get_branches
choice = display_picker(branches)
switch_branch(branches, choice)

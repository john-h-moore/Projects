#
# John H Moore  john@jhmwebdesign.com
# Ruby addressbook (using MongoDB)
# 
require 'mongo'
include Mongo

# Connect to database
@client = MongoClient.new('localhost', 27017)
@db = @client['addressbook_ruby']
@contacts = @db['contacts']

# Print contact to terminal in a pleasing format
def printContact(contact)
  contact.keys.each { |key|
    fields = ["First Name", "Middle Name/Initial", "Last Name", "Phone #1", "Phone #2", "Email", "Address #1", "Address #2", "City", "State", "Zip", "Tags"]
    puts "#{contact[key]["First Name"]} #{contact[key]["Middle Name/Initial"]} #{contact[key]["Last Name"]}"
    puts "{"
    fields.each { |field|
      puts "  #{field}: #{contact[key][field]}"
    }
    puts "}"
  }
end

# Create a new contact
def createNewContact()
  puts "\nCreate New Contact"
  contact = {}
  fields = ["First Name", "Middle Name/Initial", "Last Name", "Phone #1", "Phone #2", "Email", "Address #1", "Address #2", "City", "State", "Zip", "Tags"]
  fields.each { |field| 
    if field != "Tags"
      contact[field] = getData(field) 
    else
      contact[field] = getTags()
    end
  }
  id = @contacts.insert([
    "First Name" => contact["First Name"],
    "Middle Name/Initial" => contact["Middle Name/Initial"],
    "Last Name" => contact["Last Name"],
    "Phone #1" => contact["Phone #1"],
    "Phone #2" => contact["Phone #2"],
    "Email" => contact["Email"],
    "Address #1" => contact["Address #1"],
    "Address #2" => contact["Address #2"],
    "City" => contact["City"],
    "State" => contact["State"],
    "Zip" => contact["Zip"],
    "Tags" => contact["Tags"]
    ])
  return id
end

# Update an existing contact
def updateContact()
  puts "\nUpdate Contact"
  fields = ["First Name", "Middle Name/Initial", "Last Name", "Phone #1", "Phone #2", "Email", "Address #1", "Address #2", "City", "State", "Zip", "Tags"]
  puts "Enter some unique information (like name, phone number, and/or email) to find the contact you want to update"
  query = gets.chomp
  results = findContact(query)
  if results.length > 1
    results.keys.each_with_index { |result, index| puts "#{index} #{result}" }
    puts "Type the number of the contact you want to edit"
    print "If you do not see the contact you want, type '-1': "
    selection = gets.to_i
    contact = results[results.keys[selection]]
    fname, lname = results.keys[selection].split()
  else
    contact = results[results.keys[0]]
    fname, lname = results.keys[0].split()
  end
  fields.each_with_index { |field, index| puts "#{index} #{field}"}
  print "Select the field you want to change: "
  i = gets.to_i
  choice = fields[i]
  if choice == "Tags"
    tags = manageTags(contact)
    @contacts.update({ :$and => [{:"First Name" => fname}, {:"Last Name" => lname}]}, {:$set => {choice => tags}} )
  else
    @contacts.update({ :$and => [{:"First Name" => fname}, {:"Last Name" => lname}]}, {:$set => {choice => getData(choice)}} )
  end
  return contact
end

# Manage contact tags
# Only used to update existing contacts
def manageTags(contact)
  contact["Tags"] == nil ? currTags = [] : currTags = contact["Tags"]
  finished = false
  while !finished
    puts "Tags: #{currTags}"
    print "Do you wish to add tags or remove tags? [a] or [r]: "
    add_remove = gets.chomp
    if add_remove.downcase == "a"
      newTags = getTags()
      newTags.each{ |tag| currTags << tag }
      return currTags
    elsif add_remove.downcase == "r"
      currTags.each { |tag| puts "#{tag}" }
      print "Type the tag you want to delete: "
      toRemove = gets.chomp
      currTags.delete(toRemove)
    else
      print "You have entered an invalid choice"
    end
    print "Are you finished? [y] or [n]: "
    isFinished = gets.chomp
    if isFinished.downcase == "y"
      finished = true
    end
  end
  puts currTags
  return currTags
end

# Get user input for creating and updating contacts
def getData(key)
  print "#{key}: "
  return gets.chomp
end

# Get tags from user, return array of tags
def getTags()
  puts "Enter a tag; type 'done' when you're finished tagging"
  tags = []
  tag = getData("Tag")
  while tag.downcase != "done"
    tags << tag.downcase
    if tag != ""
      tag = getData("Tag")
    end
  end
  return tags
end

# Search for a contact
def findContact()
  puts "\nFind Contact"
  puts "Enter some search terms so we can find your contact"
  query = gets.chomp
  queries = query.split()
  results = {}
  contact = []
  queries.each { |q|
    contact << @contacts.find(
      { :$or => [
        {:"First Name" => /#{q}/},
        {:"Middle Name/Initial" => /#{q}/},
        {:"Last Name" => /#{q}/},
        {:"Phone #1" => /#{q}/}, 
        {:"Phone #2" => /#{q}/},
        {:"Email" => /#{q}/},
        {:"Address #1" => /#{q}/},
        {:"Address #2" => /#{q}/},
        {:"City" => /#{q}/},
        {:"State" => /#{q}/},
        {:"Zip" => /#{q}/},
        {:"Tags" => /#{q}/}
        ]}, 
      {:fields => ["First Name", "Middle Name/Initial", "Last Name", "Phone #1", "Phone #2", "Email", "Address #1", "Address #2", "City", "State", "Zip", "Tags"]}
      ).to_a
    contact.each{ |c|
      c.each { |foo|
        key = foo["First Name"] + " " + foo["Last Name"]
        if !results.has_key?(key)
          results[key] = foo
        end
      }
    }
  }
  return results
end

# Remove a contact
def removeContact()
  puts "\nRemove Contact"
  print "Type the first and last name of the contact you wish to remove: "
  name = gets.chomp
  fname, lname = name.split()
  contact = @contacts.find({ :$and => [{:"First Name" => fname}, {:"Last Name" => lname}]}, {:fields => ["First Name", "Middle Name/Initial", "Last Name", "Phone #1", "Phone #2", "Email", "Address #1", "Address #2", "City", "State", "Zip", "Tags"]}).to_a
  printContact(contact)
  print "Is this the user you wish to remove? [y] or [n] "
  action = gets.chomp
  if action.downcase == "y"
    print "Are you absolutely certain?  This cannot be undone! [y] or [n] "
    confirm = gets.chomp
    if confirm.downcase == "y"
      @contacts.remove({ :$and => [{:"First Name" => fname}, {:"Last Name" => lname}] })
    else
      puts "Contact will not be removed"
      return
    end
  else
    puts "Contact will not be removed"
  end
  return nil
end

# Terminal UI - used for main method
def terminal_ui()
  puts "***WELCOME***"
  options = ["Add", "Remove", "Find", "Update", "Exit"]
  done = false
  while !done
    puts "\nWhat would you like to do?"
    options.each_with_index { |option, index| puts "#{index} #{option}" }
    print "Type the number next to your choice: "
    choice = gets.chomp
    if choice[/^[0-9]+$/] == nil
      puts "\nYou have chosen poorly"
    else
      choice_i = choice.to_i
      if choice_i == 0
        contact = createNewContact()
        printContact(contact)
      elsif choice_i == 1
        contact = removeContact()
        printContact(contact)
      elsif choice_i == 2
        contact = findContact()
        printContact(contact)
      elsif choice_i == 3
        contact = updateContact()
        printContact(contact)
      elsif choice_i == 4
        puts "Goodbye"
        done = true
      else
        puts "\nYou have chosen poorly"
      end
    end
  end
end

# Main
if __FILE__ == $PROGRAM_NAME
  terminal_ui()
end
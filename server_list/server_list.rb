# ex: set softtabstop=2 shiftwidth=2 expandtab:
# Server lock RubySlim fixture.  Lock and unlock a single server from among a
# list on a page.
# Meant to be used with Rsel, but there could be other uses.
require 'fileutils'

# ServerList works with FitNesse pages containing lists of "servers".
# "Servers" refer to IPs, DNS names, or other single-word entities that you want
# listed uniquely.
class ServerList
  @@locked_servers = {}
  @@last_fitnesse_path = ""

  # Pass in the FitNesse WikiLink to a page containing some servers.  
  def initialize(fitnesse_path)
    # If path not specified, use the last one.
    fitnesse_path = @@last_fitnesse_path if fitnesse_path == ""
    raise "Page listing servers not found" unless /^<a / === fitnesse_path
    # Save this path.
    @@locked_servers[fitnesse_path] = [] unless @@locked_servers[fitnesse_path]
    init_for_path(fitnesse_path)
  end

  # Selects a server from the page given in initialization, and locks it.
  # Returns the server IP or DNS name, as given on the page.
  def get_server(name=nil)
    if name
      begin
        selected_server = get_server_by_algorithm { |l| name }
        return selected_server == name
      rescue
        return false
      end
    else
      # Mark a random server in-use.
      return get_server_by_algorithm { |l| l[rand(l.length)] }
    end
  end

  # Find the locked server and free it.
  def free_server(selected_server)
    return false unless @@locked_servers[@@last_fitnesse_path].delete(selected_server)
    edit_lines_in_file do |lines|
      return false unless lines.index { |line| /^\*#{Regexp.escape(selected_server)}( |$)/m === line }
      # Mark the selected server not-in-use.
      lines.map! { |line| (/^\*#{Regexp.escape(selected_server)}( |$)/ === line)?selected_server:line }
    end
    return true
  end

  # Free all servers that were locked by this test.
  def free_all_servers
    success = true
    last_fitnesse_path = @@last_fitnesse_path
    @@locked_servers.each do |fpath, servers| 
      init_for_path(fpath)
      edit_lines_in_file do |lines|
        lines.map! do |line|
          if /^\*/ === line
            servers.each do |selected_server|
              if /^\*#{Regexp.escape(selected_server)}( |$)/ === line
                line = selected_server 
                servers.delete(selected_server)
                break
              end
            end
            # Breakout occurs here.
          end
          line
        end # lines.map!
      end # edit_lines_in_file
      success &= (servers.length == 0)
      @@locked_servers[fpath] = []
    end
    init_for_path(last_fitnesse_path)
    return success
  end

  # Add a server to a list.
  def push_server(new_server)
    raise "Invalid server name '#{new_server}'" if /^[^!a-zA-Z0-9]/ === new_server
    edit_lines_in_file { |lines| lines.push(new_server) }
  end

  # Get the last unused server from the list
  def get_last_server
    return get_server_by_algorithm { |l| l.last }
  end

  # Delete the last unused server from the list
  # So one can be sure which server is added and used;
  # unless two people use such a page at once.
  def pop_server
    return get_server_by_algorithm(false) { |l| [ l.last, '' ] }
  end

  # Delete the first unused server from the list.  Allows a queue (fifo) instead of a stack (lifo).
  def shift_server
    return get_server_by_algorithm(false) { |l| [ l.first, '' ] }
  end

  # - Add the ability to delete a server from a list.
  def delete_server(selected_server)
    edit_lines_in_file do |lines|
      return false unless lines.index(selected_server)
      # Delete the selected server.
      lines.reject! { |line| selected_server == line }
    end
    return true
  end

  def delete_locked_server(selected_server)
    return false unless @@locked_servers[@@last_fitnesse_path].delete(selected_server)
    edit_lines_in_file do |lines|
      return false unless lines.index { |line| /^\*#{Regexp.escape(selected_server)}( |$)/m === line }
      # Delete the selected server.
      lines.reject! { |line| (/^\*#{Regexp.escape(selected_server)}( |$)/ === line) }
    end
    return true
  end
  
  # Delete all things that look like unlocked servers.
  def delete_unlocked_servers
    edit_lines_in_file { |lines| lines.reject! { |line| /^[!a-zA-Z0-9].*$/ === line } }
    return true
  end

  private

  # Continues initialize, setting up the private variables that make this work.
  # Also used to switch between paths in free_all_servers.
  def init_for_path(fitnesse_path)
    @@last_fitnesse_path = fitnesse_path
    fitnesse_path = '.'+fitnesse_path.sub(/^.*href="/,'').sub(/".*$/,'')
    @fitnesse_path = fitnesse_path
    @frpath = "FitNesseRoot"+fitnesse_path.gsub('.','/')+'/'
  end

  # Get a server, and return it, selecting the server by the algorithm given in
  # the block. The block will be given an array of server names, ordered like
  # the page, and must choose one to return. The return value may be a
  # two-element array.  The first element, or the entire value, is the selected
  # server. The second is how the server should look when "locked".  If the
  # locked version does not begin with '*' followed by the server name,
  # as the default does, then it will not be possible to "unlock" the
  # server. Sometimes this is desirable, e.g. to delete the server.
  # Blank lines ("") will also be deleted.
  #
  # Example:
  # Get a random server, and lock it with a timestamp.
  # get_server_by_algorithm { |l| s=l[rand(l.length)]; [s, "*#{s} #{Time.now}"] }
  #
  # Get the last server, and delete it!  (a.k.a. "pop" it.)  And don't lock it.
  # get_server_by_algorithm(false) { |l| [l.last, ''] }
  def get_server_by_algorithm(lock=true)
    selected_server = nil

    edit_lines_in_file do |lines|
      available_servers = []

      # Find lines containing server hostnames or IPs.
      # Ports are also allowed, so this has to be pretty general.
      if lock
        # Get a server name without spaces.
        lines.each { |line| available_servers.push(line) if /^[!a-zA-Z0-9][^ \/]* *$/ === line }
      else
        # Get a server name with spaces.  This can be almost anything, but can't and won't be locked.
        lines.each { |line| available_servers.push(line) if /^[!a-zA-Z0-9].*$/ === line }
      end
      raise "No servers found in #{@fitnesse_path}" unless available_servers.length > 0

      selected_server = yield available_servers
      # Mark in-use with a timestamp by default.
      selected_server = [ selected_server, "*#{selected_server} #{Time.now}" ] unless selected_server.is_a? Array

      # Mark the selected server in-use, or whatever
      raise "Server #{selected_server[0]} not found" unless lines.index(selected_server[0])
      lines.map! { |line| (selected_server[0] == line)?selected_server[1]:line }
    end

    selected_server = selected_server[0]

    @@locked_servers[@@last_fitnesse_path].push(selected_server) if lock

    return selected_server
  end

  # Lock a file, open it, edit the lines with the given block, save, and close it.
  def edit_lines_in_file
    locked_file = ""
    begin
      locked_file = lock_file()
      lines = IO.read(locked_file).split(/\n/)
      lines.map! { |s| s.rstrip }
      lines = yield lines
      # Blank lines ("") will always be deleted.
      lines.reject! { |line| line == '' }
      File.open(locked_file, 'w') { |f| f.write(lines.join("\n")+"\n") }
      return true
    ensure
      unlock_file(locked_file)
    end
  end

  # Rename the content.txt file on the fitnesse_path to include a random number.  
  # Returns the locked file's name, including path.
  def lock_file
    keynumber = rand(1000000000)
    newfile = "content#{keynumber}.txt"
    newpath = "#{@frpath}#{newfile}"
    lasterror = ""

    # Try for up to approximately 12 seconds
    for i in 0..13
      begin
        FileUtils.mv("#{@frpath}content.txt", newpath)
        return newpath
      rescue
        lasterror = $!
        # Sleep a random amount of time.  Primes make collisions less likely.
        sleep [1.1,1.3,0.5,0.7][rand(4)]
      end
    end
    raise "Unable to lock page #{@fitnesse_path} moving #{@frpath}content.txt to #{newpath}: #{lasterror}"
  end

  # Unlock a locked content.txt.
  # locked_name: the locked file's name, including path.
  def unlock_file(locked_name)
    begin
      FileUtils.mv("#{locked_name}","#{@frpath}content.txt")
      return true
    rescue
      return false
    end
  end

end


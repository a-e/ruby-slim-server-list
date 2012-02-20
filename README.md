Ruby Slim Server List
====

Server List is a [RubySlim](https://github.com/unclebob/rubyslim) fixture for [FitNesse](http://fitnesse.org/).  Its initial purpose was to allow [Rsel](https://github.com/a-e/rsel) tests to run on a bank of Selenium servers, automatically locking servers that are in use and freeing those that are finished.

It now also works for sharing any list of strings (without spaces and starting with an alphanumeric character) among different RubySlim fixtures and through time.  For instance, accounts set up by one script can be stored for use by another, as a stack.  Though if you have a real database server you may find [RdbFit](https://github.com/a-e/rdbfit) more useful for this purpose.

Prerequisites
-------------

Server List requires the following:

* FitNesse
* RubySlim

Installation
------------

Place the server_list directory into the FitNesse root directory.  (Not FitNesseRoot, but its parent.  From FitNesseRoot the file ../server_list/server_list.rb should exist.)

Be sure to include the following on a SetUp page above all your tests using Server List, or on each page using Server List:

!| import    |
| ServerList |

Use case with Rsel
------------------

Given that you have several Selenium servers, list their IPs or DNS names on a FitNesse page.  For instance, ".ServerList".  Lines with spaces in them that do not start with a * are assumed to be comments, so this line would not be taken as a server.  However, these would be taken as servers:

testserver1
testserver2.yourorganization.yourdomain
10.19.05.2

Next, add the following to a SetUp page, such as .TheWiki.SetUp:

 !|import     |
 | ServerList |
 
 | Script | server list | .ServerList |
 | $SVR= | get server |

This takes a random server from the list, marks it in use, and stores its value in the [symbol](http://fitnesse.org/FitNesse.UserGuide.FixtureGallery.ImportantConcepts.FixtureSymbols) $SVR.  Add the following to the corresponding TearDown page:

 | Script | server list | |
 | Free all servers |

You could specify a server list and a server to tear down, but this just cleans up everything.  Finally, in every test where you need a server name, use "$SVR".  Note that you may find it useful, for debugging purposes, to store the server name in a variable.  Then when you want to use your own machine as the server, you can say:

 !define SVR {$SVR}
 Use these to debug:
 !include -c .TheWiki.TearDown
 !define SVR {Your.server.name}

This prevents a server from winding up locked if you have to stop the test prematurely.  While you can edit the .ServerList page, you should be careful not to do so while a test is running.

To Do
-----

You may notice that the "get server" method, by default, leaves a date and time stamp after a locked server.  I plan to add a system which will kill and restart a locked server after a defined time period, e.g. an hour, and unlock the server in the server list.  At this point it may also become useful to unlock an old server and lock a new server in the middle of some long-running tests.

Copyright
---------

The MIT License

Copyright (c) 2012 Automation Excellence

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


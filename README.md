Ruby Slim Server List
====

Server List is a [RubySlim](https://github.com/unclebob/rubyslim) fixture for [FitNesse](http://fitnesse.org/).  Its initial purpose was to allow [Rsel] tests to run on a bank of Selenium servers, automatically locking servers that are in use and freeing those that are finished.

It now also works for sharing any list of strings (without spaces and starting with an alphanumeric character) among different RubySlim fixtures and through time.  For instance, accounts set up by one script can be stored for use by another, as a stack.

Prerequisites
-------------
RdbFit requires the following:

* FitNesse
* RubySlim

Installation
------------
Place the server_list directory into the FitNesse root directory.  (Not FitNesseRoot, but its parent.  From FitNesseRoot, the file ../server_list/server_list.rb should exist.)

Be sure to include the following on a SetUp page above all your tests using Server List, or on each page using Server List.

!| import    |
| ServerList |

Use case with Rsel
------------------
Given that you have several Selenium servers, place them in a 


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


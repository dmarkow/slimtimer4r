SlimTimer4R
===========

Overview
--------

A basic wrapper against the SlimTimer (www.slimtimer.com) API.

Installation
------------

Install via RubyGems: 

    gem install slimtimer4r

Usage
-----

    require 'slimtimer4r'
    
    slimtimer = SlimTimer.new("EMAIL", "PASSWORD", "API_KEY")
    tasks = slimtimer.list_tasks
        => [#<Record(Task) "name"=>"Ta...">, #<Record(Task) "name"=>"Br...">...]

The #list\_tasks and #list\_timeentries methods each return an array, which you can call standard array methods on, such as:

    tasks.collect { |task| task.hours }
        => [0.25, 1.0, 40]
    tasks.inject(0) { |total, task| total + task.hours }
        => 41.25
    tasks.collect { |task| task.hours > 20 }
        => [#<Record(Task) "hours" => 40, ...>]

Thanks
------
* 37 Signals for their sample Backpack/Basecamp Ruby wrappers

Author
------
* Dylan Markow (dylan@dylanmarkow.com)

License
-------

(The MIT License)

Copyright (c) 2010

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

AutoHotkey Help Site -- The XML
==================================
AutoHotkey Help Site is a web page that loads from an XML file to produce an interactive help experience.

The XML
-------

The XML is the data source for the site.  All questions and responces are stored in the XML file.
The structure is a bit hard to understand, but would take some work to re-format.

### The Format
The format of the file is a root node called 'HELP' which has any number of child OPTION elements.

Each of the OPTION elements has a NAME followed by a DATA.  When the user expands an option, by clicking on the NAME, they see the DATA.
They also see the NAME elements of each child OPTION.

#### Example
It looks like this
```
-help
--option
---name: TextNode Value
---data: TextNode Value
---option
----name
----data
----and so on...
```

The Editor
----------

XML isn't particularly _friendly_.  So instead you can use an editor written in AutoHotkey.

### Structure
It's configured exactly like the XML file.  It introduces some more user friendly features.

### The Buttons
The Save and Load buttons should be pretty self explainatory.  To use the New Option button, select an OPTION or the HELP node first.  It will be a child of the selected node.

Testing
-------
Upload your XML file to any web server.  You can even host it on your own server.  A free file host that has been tested to work is (http://autohotkey.net).

Then navigate your browser to (http://apps.aboutscript.com/ahkhelp/?xmlurl=%3Cfull-address-to-xml-file%3E) where <full-address-to-xml-file> is a publically reachable URI.  For example (http://apps.aboutscript.com/ahkhelp/?xmlurl=http://autohotkey.net/~frankie/test.xml).

When you've tested it, and it it works, fork this repo and commit your file.  If you can't use git, you can post a link to it here (http://www.autohotkey.com/forum/topic76455.html).

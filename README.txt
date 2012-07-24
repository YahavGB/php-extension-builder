=================================================================
		PHP Extensions builder
	By Yahav Gindi Bar (2012)
=================================================================

=================================================================
		Table of contents
	1) What is it?
	2) Requirements
	3) Simple usage
	4) After script execute
	5) Extras

=================================================================
		What is it?

PHP extension builder is a simple shell script that compile C code into PHP extension
and install it on the given PHP instance.

=================================================================
		Requirements

You should be able to run this script on each UNIX based system (NOTE THAT IT WAS TESTED ONLY ON MacOSX 10.7).
You should have PHP installed and have the PHP source code included.
I've tested this script using XAMPP (and had to install XAMPP-devel package)

=================================================================
	Simple usage

1) Set your source code files within a new directory (just because "phpize" will generate for you many files)
2) Run in the terminal:
	$ sudo /Users/yahavgindibar/php-ext-make.sh
		-b <the path to your PHP binaries directory>
		-n <the name you wish to give your PROJECT>
		-p <the name you wish to give your PRODUCT>
		-d <the path to your project directory>

For example:
$ sudo /Users/yahavgindibar/php-ext-make.sh
		-b /Applications/XAMPP/xamppfiles/bin>
		-n "PHP Hello World Extension"
		-p "hello"
		-d /Users/yahavgindibar/Desktop/hello-world-ext

Project name: the project name is the name you wish to call your extension itself (full name)
Product name: the name you wish to give to your library, has to be alphanumeric formatted (e.g. "apc", "memcache", "mysql", "sphinx", "xdebug", "pro" etc.)

For more commands execute the script with -h argument (only -h)

To clean your directory from the build files that the script generates, run
$ sudo /Users/yahavgindibar/php-ext-make.sh
		-b <the path to your PHP binaries directory>
		-n <the name you wish to give your PROJECT>
		-p <the name you wish to give your PRODUCT>
		-d <the path to your project directory>
		-c

=================================================================
		After script executed

After the script has been executed, you should restart your apache service (either by a GUI or terminal command (e.g. "service httpd restart"), then, you should see your extension in the loaded extensions.
Create a new PHP page with "phpinfo()" function, and it should be listed there - if not, you should check the build script output for errors. for any problems you can open a discussion in Github.

=================================================================
		Extras

Extra configurations exists in the script code. you can define there extra CFLAGS (which helped me solve the architecture mismatch problem I got), change the phpize and php-config file names, etc.
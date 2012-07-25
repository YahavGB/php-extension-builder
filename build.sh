#!/bin/bash

#
# Copyright (C) 2012 Yahav Gindi Bar <g.b.yahav@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# $Id$

#####################################################################
#	Configurations
#####################################################################

#   Script version
: ${PHPEXT_VERSION:="1.0.0"}

#   "phpize" script file name
: ${PHPIZE_FILE_NAME:=phpize}

#   "php-config" script file name
: ${PHP_CONFIG_FILE_NAME:=php-config}

#   Additional C flags to use
#   The current flags used in order to build the extension for i386
#   In case the produced file is not working, and you get the error "mach-o, but wrong architecture in Unknown on line 0 php extensions"
#   you should change the -arch flag to match your PHP compile architecture.
#   In my case, I'm using 64bit Mac OSX (Lion) but with XAMPP that compiled with i386 or ppc architecture. So the computer compiled the files using x86_64 architecure by default - which caused the error so I had to specify the arch.
#   In case of problem, first try to remove the arch flag, if it won't help run  the command "file <your-php-executable>" which'll gives you the architecture
#   for example:
#
#   yahavgindibar$ file /Applications/XAMPP/xamppfiles/bin/php
#   /Applications/XAMPP/xamppfiles/bin/php: Mach-O universal binary with 2 architectures
#   /Applications/XAMPP/xamppfiles/bin/php (for architecture i386):	Mach-O executable i386
#   /Applications/XAMPP/xamppfiles/bin/php (for architecture ppc):	Mach-O executable ppc
#
#   You can see that the php file compiled with i386 and ppc - which means the x86_64 won't do it, so I've changed it to i386 - and we're good to go ;)

: ${CFLAGS:="-arch i386"}

#---------------------------------
#   Set this variables in order to run the script without sending them ###
#---------------------------------

#   The project directory
#: ${PROJECT_DIR:=""}

#   The product name
#: ${PRODUCT_NAME:=""}

#   The PHP binaries directory (the path for "phpize" and "php-config" files)
#: ${PHP_BIN_DIR:=""}

#   The action to take - compile|clean|configure
: ${PHPEXT_ACTION:="compile"}

#   Create m4 and w32 files
: ${BUILD_CONFIG_FILES="YES"}

#####################################################################
#	Functions
#####################################################################

#===============================================================================
phpext_version()
{
    cat <<EOF
============================================================
PHP Extensions Builder (version $PHPEXT_VERSION)
By Yahav Gindi Bar.
License: http://www.apache.org/licenses/LICENSE-2.0.txt (Apache License v2.0)
============================================================
EOF
}

#===============================================================================

phpext_usage()
{
    : ${PHP_BIN_LOCATION:=`which php`}
    cat <<EOF
Usage: $0 [-b] [-p] [-n] [-d] [-h|-v|-c]

Required arguments:
    -b      PHP Binaries directory
    -p      Product name
    -n      Project name
    -d      Project directory

Actions:
    -h      Help
    -v      Version
    -c      Clear the project directory from last build
    -o      Only compile the project with phpize without creating m4 and w32 files
    -m      Only create configuration files without compiling the project

Simple compile usage:
sudo $0 \\
    -b "$PHP_BIN_LOCATION" \\
    -n "PHP Hello World Extension" \\
    -p "hello" \\
    -d "$HOME/hello-world-project"

In order to get your extension running, you should:
1) Run this tool, an example below and on github.
2) Adding your extension "so" file to your php.ini, this can be done by adding
    extension=\$PRODUCT_NAME.so
    to your php.ini file (\$PRODUCT_NAME is the -p argument you've send to the script - which is the library file name)
    further instructions about installing extensions at php.net
3) Recommended: make sure that the generated library got chmod 0755, this can be done by finding your extension at the php modules directory (if you don't know where it is, you can run phpinfo() function and search for "extension_dir" value) and running "chmod 0777 $PRODUCT_NAME".
4) Restart your apache httpd service.

NOTE THAT THIS SCRIPT MUST BE EXECUTED AS ADMINISTRATOR.
EOF
}

#===============================================================================

#===============================================================================

begin_task()
{
	echo
	echo "================================================================="
    echo "			$@"

	echo "================================================================="
	echo
}

#===============================================================================

message()
{
    echo "  >> $@"
}

#===============================================================================

abort()
{
    echo
    echo "Aborted: $@"
    exit 1
}

#===============================================================================

done_task()
{
    echo
    echo "    Done!"
    echo
}

#===============================================================================

create_m4_config_file()
{
	begin_task "Creating config.m4"
	
    #---------------------------------
	#	We need the project name as upper case
    #---------------------------------
    PRODUCT_NAME_UPPER="`echo $PRODUCT_NAME | tr '[:lower:]' '[:upper:]'`" 
	
    #---------------------------------
	#	We have to collect the C files to use
	#	It did kind of anoying that ALL the C files is been compiled
	#	and you don't have much contorl over it, but for first release
	#	this minimal build will do it.
    #---------------------------------
	C_FILES="`ls $PROJECT_DIR | grep -E '*.c$'`"
	C_FILES="`echo -n $C_FILES`"
	
    #---------------------------------
    #   Write the m4 file
    #---------------------------------
    message "Writing config.m4 to $PROJECT_DIR..."

	cat > config.m4 <<EOF
PHP_ARG_ENABLE($PRODUCT_NAME, whether to enable $PROJECT_NAME support,
[  --enable-$PROJECT_NAME           Enable $PROJECT_NAME support])

if test "\$PHP_$PRODUCT_NAME_UPPER" = "yes"; then
  AC_DEFINE(HAVE_$PRODUCT_NAME_UPPER, 1, [Whether you have $PROJECT_NAME])
  PHP_NEW_EXTENSION($PRODUCT_NAME, $C_FILES, \$ext_shared)
fi
EOF
	
	done_task
}

#===============================================================================

create_w32_config_file()
{
	begin_task "Creating config.w32"
	
    #---------------------------------
    #	We need the project name as upper case
	#---------------------------------
    PRODUCT_NAME_UPPER="`echo $PRODUCT_NAME | tr '[:lower:]' '[:upper:]'`" 
	
    #---------------------------------
	#	We have to collect the C files to use
	#	It did kind of anoying that ALL the C files is been compiled
	#	and you don't have much contorl over it, but for first release
	#	this minimal build will do it.
    #---------------------------------
	C_FILES="`ls $PROJECT_DIR | grep -E '*.c$'`"
	C_FILES="`echo -n $C_FILES`"
	
    #---------------------------------
	#	Write the w32 file
    #---------------------------------
    message "Writing config.w32 to $PROJECT_DIR..."

	cat > config.w32 <<EOF
ARG_ENABLE("$PRODUCT_NAME", "$PROJECT_NAME support", "yes");

if (PHP_$PRODUCT_NAME_UPPER == "yes") {
	EXTENSION("$PRODUCT_NAME", "$C_FILES");
	AC_DEFINE('HAVE_$PRODUCT_NAME_UPPER', 1, 'Whether you have $PROJECT_NAME');
}
EOF

	done_task
}

#===============================================================================

clean_using_phpize()
{
    begin_task "Cleaning project using phpize"
    `$PHP_BIN_DIR/$PHPIZE_FILE_NAME --clean`
    done_task
}

#===============================================================================

clean_config_files()
{
    begin_task "Cleaning project configuration files"
    rm $PROJECT_DIR/config.m4
    rm $PROJECT_DIR/config.w32
    done_task
}

#####################################################################
#	Program
#####################################################################

#---------------------------------
#   Check for root privileges, we have to get them
#   in order to successfully run the make and make instal commands
#---------------------------------

if [ "$(id -u)" != "0" ]; then
    case $@ in
        -h)
            phpext_usage
            exit 0
        ;;
    esac

    echo "This script must be run as root" 1>&2
    exit 1
fi

#---------------------------------
#	Parse the arguments
#---------------------------------

while getopts ":b:n:p:d:vhco" opt; do
    case $opt in
####################################################
        v)
            phpext_version
            exit 0
        ;;
        h)
            phpext_usage
            exit 0
        ;;
####################################################
        b)
           PHP_BIN_DIR=$OPTARG
        ;;
        n)
            PROJECT_NAME=$OPTARG
        ;;
        p)
            PRODUCT_NAME=$OPTARG
        ;;
        d)
            PROJECT_DIR=$OPTARG
        ;;
####################################################
        c)
            PHPEXT_ACTION="clean"
        ;;
        m)
            PHPEXT_ACTION="configure"
        ;;
        o)
            BUILD_CONFIG_FILES="NO"
        ;;
####################################################
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
        ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
        ;;
    esac
done

#---------------------------------
#	Requirements
#---------------------------------

[ -d $PHP_BIN_DIR ] || abort "Could not find PHP binary directory."

[ -f $PHP_BIN_DIR/$PHPIZE_FILE_NAME ] || abort "Could not find phpize in the PHP binaries directory ($PHP_BIN_DIR/$PHPIZE_FILE_NAME)."

if [ -z $PRODUCT_NAME ]; then
    abort "No product name supplied."
fi

[ -d $PROJECT_DIR ] || abort "Could not find the project directory."


#---------------------------------
#	Start
#---------------------------------
cd $PROJECT_DIR
echo "      PHP Extension Builder"
echo "Project Name:         $PROJECT_NAME"
echo "Project Dir:          $PROJECT_DIR"
echo "Product Name:         $PRODUCT_NAME"
echo "PHP Binaries Dir:     $PHP_BIN_DIR"
echo "-----------------------------------------------------"
echo
echo

#---------------------------------
#   Clean or compile
#---------------------------------

if test $PHPEXT_ACTION = "clean"; then
    #   Clean using phpize
    clean_using_phpize

    #   Remove configuration files
    if test $BUILD_CONFIG_FILES = "YES"; then
        clean_config_files
    fi
    exit 0
elif test $PHPEXT_ACTION = "configure"; then
    #	".m4" file for Linux based OS
    create_m4_config_file

    #	".w32" file for Windows based OS
    create_w32_config_file

    exit 0
fi

#---------------------------------
#   Create the configuration files
#---------------------------------
if test $BUILD_CONFIG_FILES = "YES"; then
	#---------------------------------
	#	Create config files (m4 and win32)
	#---------------------------------
	
	#	".m4" file for Linux based OS
	create_m4_config_file
	
	#	".w32" file for Windows based OS
	create_w32_config_file
fi

#---------------------------------
#	Run
#---------------------------------

begin_task "Generating extension using $PHPIZE_FILE_NAME"
echo `$PHP_BIN_DIR/$PHPIZE_FILE_NAME`
done_task

begin_task "Executing the generated configure file"

sudo $PROJECT_DIR/configure \
        CFLAGS="$CFLAGS" \
        --enable-$PRODUCT_NAME \
        --with-php-config=$PHP_BIN_DIR/$PHP_CONFIG_FILE_NAME

done_task

begin_task "Making (let the fun begin!)"
sudo make
sudo make install
done_task

begin_task "Verifying that the make succeeded"
sudo make test
done_task

echo "

    Thats it.
    For further instructions, run $0 -h.

    Don't forget to restart the apache httpd service.

"

exit 0
#!/usr/bin/env python
# -*- coding: UTF-8 -*- 
# Distribution setup file
#-----------------------------------------------------------------------------

try:
	import os,stat, re, sys, platform,shutil, inspect, difflib
	import subprocess

	from os.path import abspath, dirname, join

	from esky import bdist_esky

	from setuptools import setup, find_packages
	from distutils.core import setup
	from cx_Freeze import setup, Executable

	#from distutils.command.build_py import build_py
	#from distutils.command.sdist import sdist
	#from disutils.core import setup
	#from distutils.core import setup
	#import py2exe

except ImportError:
    #return None
    print "Try to install dependences .."

except Exception, e:
	raise e

#Variables

os_type = sys.platform 
os_sys = platform.system()

#
# Run the build process by running the command 'python setup.py build'
#

application_title = "erpmtics" #application to be called
main_python_file = "main.py" #the name of the python file you use to run the program



# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

#https://github.com/pyinstaller/pyinstaller/blob/develop/setup.py

DESC = ('Python app for manager it: run comands remote mode under Windows, Linux or Mac OS X into stand-alone')


LONG_DESC =read('README')

LONG_DESC = """
erpmtics is a program that try eject commans on remote machines
under Windows, Linux, Mac OS X.

For example run a .vbs on windows, or a .sh on Linux and Mac OS X

Its main advantages over similar tools are that
erpmtics works with any version of Python since 2.7, multi-platform,
and uses the OS support to load the dynamic libraries, thus ensuring full
compatibility.

"""
#http://paulfurley.com/packaging-python-for-windows-pyinstaller-wine/

'''

http://www.pyinstaller.org/

https://pypi.python.org/pypi/setuptools/#windows-8-powershell


'''



"""

try:
    from ve_setup import use_virtualenv
except ImportError:
    import urllib
    urllib.retrive("http://tiny.cc/ve-setup", 've_setup.py')
    from ve_setup import use_virtualenv

use_virtualenv(['--distribute', "python"], requirements="requirements.pip")

"""

#if __name__ == "__main__" :

#https://pypi.python.org/pypi/setuptools/
#https://github.com/pyinstaller/pyinstaller
base = None

try:

        if os_type =="linux2" and os_sys =="Linux":
            print "##################################Linux"
            #linux
            exeICON = None
            FREEZER = None
            FREEZER_OPTIONS = None

            #Note that you will may need to invoke the command with superuser privileges to install to the system Python:
            #wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python

            #Alternatively, Setuptools may be installed to a user-local path:

            #wget https://bootstrap.pypa.io/ez_setup.py -O - | python - --user


            #printer_linux = Printer(strategy=PrinterLinux)
            #print printer_linux.add_printer('AD')
            #printer_linux = Printers(PrinterLinux)
        elif os_type =="win32" and os_sys =="Windows":
            print "##################################Windows"
            base = "Win32GUI"
            '''
			shortcut_table = [
    							("DesktopShortcut",        # Shortcut
     							"DesktopFolder",          # Directory_
     							"DTI Playlist",           # Name
     							"TARGETDIR",              # Component_
     							"[TARGETDIR]playlist.exe",# Target
     							None,                     # Arguments
     							None,                     # Description
     							None,                     # Hotkey
     							None,                     # Icon
     							None,                     # IconIndex
     							None,                     # ShowCmd
     							'TARGETDIR'               # WkDir
     		)
    		]    		

    		# Now create the table dictionary
    		msi_data = {"Shortcut": shortcut_table}
    		# Change some default MSI options and specify the use of the above defined tables
    		bdist_msi_options = {'data': msi_data}
    		'''

            import py2exe

            sys.path.append("C:\\Program Files\\Microsoft Visual Studio 9.0\\VC\\redist\\x86\\Microsoft.VC90.CRT")

            FREEZER = 'py2exe'
            FREEZER_OPTIONS = dict(compressed = 0,
                           optimize = 0,
                           bundle_files = 3,
                           dll_excludes = ['MSVCP90.dll',
                                           'mswsock.dll',
                                           'powrprof.dll', 
                                           'USP10.dll',],
                        )
            exeICON = 'erpmtics.ico'
            bdist_msi_options = {
            	'upgrade_code': '{66620F3A-DC3A-11E2-B341-002219E9B01E}'
            	,'add_to_path': False
            	,'initial_target_dir': r'[ProgramFilesFolder]\%s\%s' % (application_title, application_title)
            }

            build_exe_options = {
            	'includes': ['atexit', 'PySide.QtNetwork']
			}



            #Windows 8 (Powershell)

            #Invoke-WebRequest https://bootstrap.pypa.io/ez_setup.py).Content | python 

			#windows 7
			#https://bootstrap.pypa.io/ez_setup.py


            #windows
            #printer_win = Printer(strategy=PrinterWindows)
            #print printer_win.add_printer('AD')
            #printer_win = Printers(PrinterWindows)
        elif os_type =="darwin" and os_sys =="Darwin":
            print "##################################OS X"
            import py2app

            FREEZER = 'py2app'
            FREEZER_OPTIONS = dict(argv_emulation = False, 
                           iconfile = 'erpmtics.icns',
                           )
            exeICON = None
            #Mac OS x
            #brew install python 
            #curl https://bootstrap.pypa.io/ez_setup.py -o - | python

            #printer_osx = Printer(strategy=PrinterMac)
        else:
            print os_type + "Unknow"

        #print printer_linux.find("x")            

except Exception, e:
        print "The following exception was expected:"
        print e


# Common settings  
APP = [bdist_esky.Executable("main.py", 
                             gui_only=True
                             ,icon=exeICON
                             )]
#DATA_FILES = [ 'erpmtics.ico' ]
ESKY_OPTIONS = dict( freezer_module     = FREEZER
                     ,freezer_options    = FREEZER_OPTIONS
                     ,enable_appdata_dir = True
                     ,bundle_msvcrt      = True
                     )
    
'''
    ,install_requires=[
        'M2Crypto'
        # PyQt4 is also required, but it doesn't play nicely with setup.py
    ]

 options={
          'bdist_msi': bdist_msi_options,
          'build_exe': build_exe_options})
executables = [
        Executable(
            "MyApp.py",
            shortcutName="DTI Playlist",
            shortcutDir="DesktopFolder",
            )
        ]

options = {
        "bdist_msi": bdist_msi_options,
    },
    executables = [
        Executable(
            "MyApp.py",
            )
        ]
    )

''' 

includes = ["atexit","re"]   

# Build the app and the esky bundle
setup(
	install_requires=['setuptools','bbfreeze','cx_Freeze']
	,packages=find_packages()
	,package_data={
        'erpmtics': ['images/*.png', 'images/light/*.png', 'images/dark/*.png']
    }

	,name =application_title
	,version = "0.2"
	,description=DESC
    ,long_description=LONG_DESC
    ,keywords='erpmtics, python, manager it'
    ,author='Armando Ibarra'
    ,author_email='armandoibarra1@gmail.com'
    ,maintainer='Armando Ibarra'
    ,maintainer_email='armandoibarra1@gmail.com'
    ,license=('GPL license with a special exception which allows to use '
             'erpmtics to build and distribute non-free programs '
             '(including commercial ones)')
    ,url='http://artpcweb.appspot.com'
    ,download_url='http://artpcweb.appspot.com/projects/erpmtics/manager'
    ,scripts=APP #,"appname/gui/script2.pyw"]
    #,options = dict(bdist_esky=ESKY_OPTIONS) #{"build_exe" : {"includes" : includes }}
    #,executables = [Executable(main_python_file)] #, base = base)]
    #,data_files = DATA_FILES,
    #,options={"bdist_esky":{"includes":["mylib"]}},
	#,console = ["main.py"]
	)



     
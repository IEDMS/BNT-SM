The Geodise Toolboxes for Matlab (GeodiseLab release 1.1)

http://www.geodise.org/

Copyright 2005, Geodise Project, University of Southampton

Graeme Pound (gep@soton.ac.uk)
Jasmin Wason (j.l.wason@soton.ac.uk)
Marc Molinari (m.molinari@soton.ac.uk)

$Date: 2005/05/12 10:51:04 $
$Revision: 1.10 $

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Description:

The Geodise Toolboxes provide a collection of functions that extend the 
capability of the Matlab[http://www.mathworks.com] technical computing 
environment. The Geodise Compute, Database and XML toolboxes contain 
routines that facilitate many aspects of Grid computing and data 
management including:

    * The submission and management of computational job on remote 
	compute resources via the Globus GRAM service.
    * File transfer and remote directory management using the GridFTP 
	protocol.
    * Single sign-on to the Grid with Globus proxy certificates.
    * Storage and grouping of files and variables, annotated with user
	defined metadata, in an archive.
    * Graphical and programmatic interfaces for querying the metadata to 
	easily locate files and variables.
    * Sharing and reuse of data among distributed users. Users may grant
	access to their data to other members of a Virtual Organisation.
    * Conversion of Matlab structures and variables into a non-proprietary, 
	plain text format (XML) which can be stored and used by other 
	tools.
    * Conversion of almost any type of XML document including WSDL 
	descriptions of Web Services into Matlab's struct format or cell 
	data type.

Further details are available in the Geodise manual doc\GeodiseManual.pdf.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Installation:

Prerequisites:
	Matlab 6.5 (release 13),
	Matlab 7.0 (release 14), or
	Matlab 7.0.1 (release 14 Service Pack 1) 

Supported platforms:
	Windows XP, Red Hat Linux 7.3

Please see the document doc\INSTALL.pdf for instructions about how to 
install the Geodise Toolboxes. Alternatively toolbox specific instructions 
are contained within the file 'INSTALL.TXT' in the base directory of 
each toolbox.

The Geodise Toolboxes are distributed separately for Matlab 6.5 and 7
(this is due to a bug in the Matlab 7 release which prevents backwards
compatibility [1]). Please use the distribution appropriate for the 
release of Matlab that you use.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Licensing:

The software license for each toolbox is included at the in the base 
directory of each toolbox.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Known Issues:

#1: Matlab 7.0.1 prints Log4J logging information (Linux and Windows)
The output of some Grid functions are unnecessarily verbose when using 
Matlab 7 [SP1].To correct this comment the following line in the 
classpath.txt file:

	$matlabroot/java/jarext/axis.jar

A copy of axis.jar which does not cause this behaviour is supplied with 
the Database Toolbox.


#2: Classpath errors are reported as a Segmentation violation (Linux 
and Windows)
When the functions of the Compute and Database Toolboxes are invoked with 
an incorrectly configured classpath.txt (see installation documentation)
the resulting classpath error is reported as a segmentation violation.
This can be resolved by adding the required Java libraries to the Matlab 
classpath and restarting Matlab.

#3: Matlab 7.0.4 (release 14 Service Pack 2) is not supported.

#4: Some releases of Matlab 7 ship with Java 1.4.2_05
Java versions 1.4.2_05 and 1.4.2_06 contain an old version of Xalan which 
causes an exception in the Apache XML Security software used by 
the Database Toolbox. To determine the version of Java used by Matlab type:

	>> version -java

Copy xalan.jar from <INSTALL_DIR>/lib/ to 
<MATLAB_HOME>/sys/java/jre/<OS>/jre/lib/endorsed/ to correct this. Create 
the endorsed directory in <MATLAB_HOME>/sys/java/jre/<OS>/jre/lib/ if it 
does not exist.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[1] Solution Number: 1-PABV3
http://www.mathworks.com/support/solutions/data/1-PABV3.html?solution=1-PABV3

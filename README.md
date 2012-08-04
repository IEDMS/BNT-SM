BNT-SM
======

Bayes Net Toolbox for Student Modeling (BNT-SM) is an effort to facilitate the use of dynamic Bayes nets in the student modeling community.

BNT-SM inputs a data set and a compact XML specification of a Bayes net model hypothesized by a researcher to describe causal relationships among student knowledge and observed behavior. BNT-SM generates and executes the code to train and test the model using the Bayes Net Toolbox. BNT-SM allows researchers to easily explore different hypothesis with respect to the knowledge representation in a student model. For example, by varying the graphical structure of a Bayesian network, we examined how tutoring intervention can affect students' knowledge state - whether the intervention is likely to scaffold or to help students to learn.

INSTALL
======

BNT-SM is implemented in Matlab, so you need to have Matlab installed and running.

TYPICAL USAGE EXAMPLES
======

With BNT-SM downloaded and extracted, launch Matlab and do

  >> cd src
	
	>> setup

	>> cd ../model/kt

	>> [property evidence hash_bnet] = RunBnet('property.xml');
	
1. Property.xml is an XML file that specifies the Bayes net we are constructing.
2. In the directory, BNT-SM/model, you can find some other sample Bayes net specification and a small test set to get started.
3. Now, BNT-SM also supports logistic regression in a Dynamic Bayes net (LR-DBN), which can be found in BNT-SM/model/lr-dbn.

A Walk-through Example of modeling Knowledge Tracing with BNT-SM can be found at http://www.cs.cmu.edu/~listen/BNT-SM/kt.html

An Example of tracing multiple subskills with BNT-SM can be found at http://www.cs.cmu.edu/~listen/BNT-SM/lr-dbn%20example.pdf

CONTACT US
======
Yanbo Xu <yanbox at cs dot cmu dot edu>
Kai-min Chang <kaimin dot chang at gmail dot com>

CITE
======
Chang, K., Beck, J., Mostow, J., & Corbett, A. (2006, June 26-30). A Bayes Net Toolkit for Student Modeling in Intelligent Tutoring Systems. Proceedings of the 8th International Conference on Intelligent Tutoring Systems, Jhongli, Taiwan, 104-113.

If you are running LR-DBN with BTN-SM, please cite:

Xu, Y., & Mostow, J. (2011, July 6-8). Using Logistic Regression to Trace Multiple Subskills in a Dynamic Bayes Net. In M. Pechenizkiy, T. Calders, C. Conati, S. Ventura, C. Romero, & J. Stamper (Eds.), Proceedings of the 4th International Conference on Educational Data Mining (pp. 241-245). Eindhoven, Netherlands.


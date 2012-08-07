############################################################################
## BNT-SM 08/31/2006 created by Kai-min Chang                             ##
## BNT-SM 09/18/2007 updated by Kai-min Chang                             ##
## BNT-SM 03/18/2012 extended by Yanbo Xu, to support LR-DBN              ##
## ------------------ debug info by Yanbo ------------------------------- ##
##                   Date: 2011-11-12                                     ##
## 1. Fix the following problems of BNT-SM:                               ##      
##   1) [./src/bnet/inference_bnet.m]:                                    ##  
##			take marginal of "L0" for first test evidence,                    ##                  
##			then take "learn, forget" for the rest.                           ##          
##   2) [./src/RunBnet.m]:                                                ##
##  		fclose(fid_log) after catching an error, then return.             ##                        
##                                                                        ## 			
## 2. New features in BNT-SM:                                             ##
##	 1) Add [./src/TestBnet.m]:                                           ##		 
##			Can now test on new evidence based on existing "hash_bnet.mat"    ##
##			Usage: [property evidence hash_bnet] = ...                        ##
##								TestBnet(property_xml file name, test_evidence file...  ##
##								name, inference_result file name)                       ##
## 	 2) Add [./src/RunLRBnet.m]                                           ##
##					[./src/TestLRBnet.m]:                                         ##
##					[./src/util/extract_LRParam.m]                                ##
##					[./src/util/setup_LRoutput.m]                                 ##
##					[./src/evidence/table2LRevidence.m]                           ##
##					[./src/bnet/extract_LRbnet.m]                                 ##
##					[./src/bnet/inference_LRbnet.m]                               ##
##					[./src/bnet/make_LRbnet.m]:                                   ##
##			Can now fit LR-DBN                                                ##
## 3. Something still need to be checked in:                              ##
##	 1) "initial value" is not used in EM.                                ##
##                                                                        ##		
## NOTE: about property.xml for LR-DBN:                                   ##
## 1) No inference_prior                                                  ##
## 2) No dirichlet_prior                                                  ##
## 3) <multi_subskill> must be yes                                        ##
## 4) node's type: multi( only one node can have such typ), discrete      ##
##   eclass's type: root, softmax, discrete                               ##
############################################################################   

The code in this package can be originally found at:

lib/FullBNT: SourceForge (http://bnt.sourceforge.net/), somewhere before release 1.0.0

lib/GeodiseLab: Geodise site (http://www.geodise.org/toolboxes/generic/xml_toolbox.htm)

lib/hashtable: Matlab Central (http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6514&objectType=FILE)

lib/logistic: Geoffrey Gordon's web page (http://www.cs.cmu.edu/~ggordon/IRLS-example/)

lib/mym: Matlab Central (http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=11913&objectType=file)

lib/roc: Gavin Cawley's web page (http://theoval.sys.uea.ac.uk/matlab/default.html)

lib/util: Kai-min's, Yanbo's

src: Kai-min's, Yanbo's

############################################################################ 
##           Old BNT-SM 09/18/2007, without LR-DBN                        ##
############################################################################
Assuming you're at $LISTEN\StudentModel\BNT-SM, and you want to create
the setup to train and test the project "my_model".


Training data
=============

Create a file (say, 'train.sql') containing the query that generates
training data, notice the 'a' in user.list:

- train.sql:
================================== START HERE ==================================================
select
    data.user_id     as user,
    machine_name,
    utterance_start_time,
    utterance_sms,
    target_word_number,
    target_word      as skill,
    helped+1         as help,
    null             as knowledge,
    null             as correct,
    trn_correct+1    as trn_correct,
    center_context+1 as asr_accept,
    confidence_score,
    if(confidence_score=-1, null, floor(confidence_score*100/20)+1) as asr_confidence

from
    egouvea.lex_view_2004_2005      as data,
    kkchang.user_list_ab_2004_2005  as user
   
where
    user.list = 'a'
    and data.user_id = user.user_id
    and data.user_id != 'Student List Unavailable'
    and target_word != ''
order by
    skill,
    user,
    utterance_start_time,
    utterance_sms
================================== END HERE ==================================================


Execute the query and redirect it to a file, location hardwired in config file:

> mysql -h vicissitude -u <your_user_id> -p < train.sql > model/my_model/evidence.train.xls


Test data
=========

Create a file (say, 'test.sql') containing the query that generates
test data, notice the 'b' in user.list:

- test.sql:
================================== START HERE ==================================================
select
    data.user_id     as user,
    machine_name,
    utterance_start_time,
    utterance_sms,
    target_word_number,
    target_word      as skill,
    helped+1         as help,
    null             as knowledge,
    null             as correct,
    trn_correct+1    as trn_correct,
    center_context+1 as asr_accept,
    confidence_score,
    if(confidence_score=-1, null, floor(confidence_score*100/20)+1) as asr_confidence

from
    egouvea.lex_view_2004_2005      as data,
    kkchang.user_list_ab_2004_2005  as user
   
where
    user.list = 'b'
    and data.user_id = user.user_id
    and data.user_id != 'Student List Unavailable'
    and target_word != ''
order by
    skill,
    user,
    utterance_start_time,
    utterance_sms
================================== END HERE ==================================================

Execute the query and redirect it to a file, location hardwired in config file:

> mysql -h vicissitude -u <your_user_id> -p < test.sql > BNT-SM/model/my_model/evidence.test.xls

OOV

To create the data for oov estimation, process the input data through
the script below (e.g. by saving the script to a file, say, filter.pl,
and then running perl filter.pl < evidence_train.xls >
oov_evidence_train.xls).

================================== START HERE ==================================================
while (<>) {
  chomp();
  @line = split /\t/; 
  if (m/\d/) {
    $line[0] .= $line[1] . $line[5]; 
    $line[5] = "OOV";
  }
  $out = join("\t", @line); 
  print $out . "\n";
}
================================== END HERE ==================================================


Training the model
==================

Start matlab

matlab> cd src
matlab> setup
matlab> cd ../model/my_model
matlab> [property evidence hash_bnet] = RunBnet('property.xml');


You will find the output model in model/my_model/param_table.xls and the
results in model/my_model/inference_results.xls


Evaluating the model
====================


Before uploading the model into mysql, you need to create the table
that will hold it. In this example, let's call this table "now":


mysql >
================================== START HERE ==================================================
CREATE TABLE `now` (
  `user_id` char(50) default NULL,
  `machine_name` char(50) default NULL,
  `utterance_start_time` datetime default NULL,
  `utterance_sms` int(11) default NULL,
  `target_word_number` int(11) default NULL,
  `target_word` char(64) default NULL,
  `help` bigint(1) default NULL,
  `knowledge` double default NULL,
  `correct` double default NULL,
  `trn_correct` int(1) default NULL,
  `asr_accept` int(1) default NULL,
  `confidence` double default NULL,
  `asr_confidence` int(1) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
================================== END HERE ==================================================


To upload the results table into the database:

mysql> 
load data local infile 'inference_result.xls' into table now fields terminated by '\t';

To evaluate the inference results:

mysql >
================================== START HERE ==================================================
select count(*) as num_words, 
count(distinct word), min(word), max(word),
knowledge = 0,
trn_correct, 
pow(2,floor(log2(s.total))) as bin,
avg(asr_accept = 2) as acceptance_rate,
avg(asr_accept = 1) as rejection_rate,
1 - avg(confidence > .02) as 'confidence_>_.02',
1 - avg(correct > .02) as 'correct_>_.02',
1 - avg(confidence > .05) as 'confidence_>_.05',
1 - avg(correct > .05) as 'correct_>_.05',
1 - avg(confidence > .10) as 'confidence_>_.10',
1 - avg(correct > .10) as 'correct_>_.10',
1 - avg(confidence > .20) as 'confidence_>_.20',
1 - avg(correct > .20) as 'correct_>_.20',
1 - avg(confidence > .30) as 'confidence_>_.30',
1 - avg(correct > .30) as 'correct_>_.30',
1 - avg(confidence > .40) as 'confidence_>_.40',
1 - avg(correct > .40) as 'correct_>_.40',
1 - avg(confidence > .50) as 'confidence_>_.50',
1 - avg(correct > .50) as 'correct_>_.50',
1 - avg(confidence > .60) as 'confidence_>_.60',
1 - avg(correct > .60) as 'correct_>_.60',
1 - avg(confidence > .70) as 'confidence_>_.70',
1 - avg(correct > .70) as 'correct_>_.70',
1 - avg(confidence > .80) as 'confidence_>_.80',
1 - avg(correct > .80) as 'correct_>_.80',
1 - avg(confidence > .90) as 'confidence_>_.90',
1 - avg(correct > .90) as 'correct_>_.90'
from now,
training_data_word_stat s
where now.target_word = s.word
and trn_correct != 0
group by knowledge=0,
trn_correct,
bin;
================================== END HERE ==================================================


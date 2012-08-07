% 0. init

%profile on;

temp = pwd;
current_dir = temp(1:length(temp)-3);

path(path, [current_dir '/src']);
path(path, [current_dir '/src/bnet']);
path(path, [current_dir '/src/evidence']);
path(path, [current_dir '/src/util']);
path(path, [current_dir '/lib/GeodiseLab/XMLToolbox']);
path(path, [current_dir '/lib/hashtable']);
path(path, [current_dir '/lib/logistic']);
path(path, [current_dir '/lib/mym']);
path(path, [current_dir '/lib/roc']);
path(path, [current_dir '/lib/util']);

path(path, [current_dir '/lib/FullBNT/BNT']);
global BNT_HOME;
BNT_HOME = [current_dir '/lib/FullBNT'];
add_BNT_to_path;

seed = 12345;
rand('state', seed);
randn('state', seed);

%profile off;
%profile viewer;

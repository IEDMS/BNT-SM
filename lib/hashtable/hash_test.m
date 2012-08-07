
hash = hashtable;
hash = put(hash,'a',1);
hash = put(hash,'random numbers',rand(5));
hash = put(hash,'b','abcdefg...');
hash = put(hash,'c',{'foo' 'goo' 'moo'});

s.title = 'Random Numbers and Mean';
s.data = rand(100);
s.m = mean(s.data);

hash = put(hash,'my data struct',s);
hash

iskey(hash,'random numbers')
get(hash,'random numbers')
hash = remove(hash,'random numbers');
iskey(hash,'random numbers')

k = keys(hash);
v = values(hash);
newhash = hashtable(k,v)

isempty(hash)
hash = clear(hash);
isempty(hash)

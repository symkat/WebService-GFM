use inc::Module::Install;
  
# Define metadata
name           'WebService-GFM';
all_from       'lib/WebService/GFM.pm';
license        'perl';

# Specific dependencies
requires       'LWP::UserAgent' => '0';
requires       'JSON'           => '0';
requires       'HTTP::Request'  => '0';

WriteAll;

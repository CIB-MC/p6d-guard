requires 'Amon2', '6.16';
requires 'Crypt::CBC';
requires 'Crypt::Rijndael';
requires 'DBD::SQLite', '1.33';
requires 'HTML::FillInForm::Lite', '1.11';
requires 'HTTP::Session2', '1.03';
requires 'JSON', '2.50';
requires 'Module::Functions', '2';
requires 'Plack::Middleware::ReverseProxy', '0.09';
requires 'Router::Boom', '0.06';
requires 'Starlet', '0.20';
requires 'Teng', '0.18';
requires 'Test::WWW::Mechanize::PSGI';
requires 'Text::Xslate', '2.0009';
requires 'Time::Piece', '1.20';
requires 'perl', '5.010_001';
requires 'HTTP::Session2::ServerStore', '1.10';
requires 'Cache::Memcached::Fast::Safe', '0.06';
requires 'Module::Find', '0.16';
requires 'Digest::SHA', '6.04';
requires 'String::Random', '0.32';
requires 'FormValidator::Lite', '0.32';

on configure => sub {
    requires 'Module::Build', '0.38';
    requires 'Module::CPANfile', '0.9010';
};
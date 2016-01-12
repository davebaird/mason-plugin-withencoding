requires "Capture::Tiny" => "0.01";
requires "Encode" => "0";
requires "Guard" => "0.1";
requires "Mason" => "2.13";
requires "Moose" => "0.34";
requires "Plack::Request::WithEncoding" => "0";
requires "Poet" => "0.04";
requires "Try::Tiny" => "0.01";
requires "encoding::warnings" => "0";
requires "perl" => "v5.12.0";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "Test::Class" => "0";
  requires "Test::Class::Most" => "0";
  requires "Test::More" => "0";
  requires "perl" => "v5.12.0";
};

on 'configure' => sub {
  requires "Module::Build" => "0.28";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::EOL" => "0";
  requires "Test::More" => "0.88";
  requires "Test::Pod::Coverage" => "1.08";
  requires "perl" => "5.006";
  requires "strict" => "0";
  requires "warnings" => "0";
};

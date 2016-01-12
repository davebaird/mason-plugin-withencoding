requires "Capture::Tiny" => "0";
requires "Encode" => "0";
requires "Guard" => "0";
requires "Mason" => "2.13";
requires "Mason::Plugin" => "0";
requires "Mason::PluginRole" => "0";
requires "Moose" => "0";
requires "Poet" => "0";
requires "Poet::Tools" => "0";
requires "Test::Class::Most" => "0";
requires "Try::Tiny" => "0";
requires "utf8" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "Test::More" => "0";
  requires "perl" => "5.006";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
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

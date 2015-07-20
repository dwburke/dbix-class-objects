use Test::Most;
use lib 't/lib';
use My::Fixtures;
use Sample::Schema;

my $schema = Sample::Schema->test_schema;

my $fixtures = My::Fixtures->new( { schema => $schema } );
$fixtures->load('user');

my $user = $schema->resultset('User')->first;
my $session = $schema->resultset('Session')->first;

my $uid = $user->username;
$session->username($uid);
$session->update();
is $session->username->username, $user->username, "storing in a nullable relation works";

my $db_session = $schema->resultset('Session')->first;
is $db_session->username->username, $user->username, "...and that's actually in the db now";

# assuming tests above went wrong, force it:
$db_session->username($uid);
$db_session->update();

$session = $schema->resultset('Session')->first; # why must moose obj be reloaded?

is ref($session->username), "Sample::Schema::Result::User", "username refers to the right class";

$session->username(undef);
$session->update();

is $session->username, undef, "nulling the relation works";

done_testing;

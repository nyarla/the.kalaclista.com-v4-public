use strict;
use warnings;
use utf8;

package Kalaclista::Parallel;

use Parallel::Fork::BossWorkerAsync;
use Path::Tiny::Glob;

our $THREADS = 31;

sub new {
  my ( $class, %opts ) = @_;

  if ( !exists $opts{'processor'} || ref( $opts{'processor'} ) ne 'REF' ) {
    die "argument 'processor' required as subroutine reference";
  }

  if ( !exists $opts{'prepare'} || ref( $opts{'prepare'} ) ne 'REF' ) {
    die "argument 'prepare' required as subroutine reference";
  }

  return bless \%opts, $class;
}

sub lookup {
  my ( $self, @glob ) = @_;

  my @tasks;
  my $files = pathglob( \@glob );
  while ( defined( my $file = $files->next ) ) {
    push @tasks, $self->{'prepare'}->($file);
  }

  return \@tasks;
}

sub process {
  my ( $self, @args ) = @_;
  return $self->{'processor'}->(@args);
}

sub run {
  my $self = shift;
  my @args = @_;

  my $tasks = $self->lookup(@args);

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler  => sub { return $self->process(@_); },
    handle_result => sub { return $_[0] },
    worker_count  => $THREADS,
  );

  $bw->add_work( $tasks->@* );
  while ( $bw->pending ) {
    my $ref = $bw->get_result;
    if ( exists $ref->{'ERROR'} && $ref->{'ERROR'} ne q{} ) {
      print STDERR $ref->{'ERROR'}, "\n";
    }
    else {
      print $ref->{'message'}, "\n";
    }
  }

  $bw->shut_down();

  return 1;
}

1;

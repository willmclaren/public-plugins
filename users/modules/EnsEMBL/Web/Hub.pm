package EnsEMBL::Web::Hub;

use strict;

use ORM::EnsEMBL::DB::Accounts::Manager::User;
use EnsEMBL::Web::User;
use EnsEMBL::Web::Exceptions;
# use EnsEMBL::Web::Configuration::Account;

use EnsEMBL::Web::Tools::MethodMaker (copy => {map {$_ => "__$_"} qw(new url get_favourite_species)});

use constant CSRF_SAFE_PARAM => 'rxt';

sub PREFERENCES_PAGE  { return shift->url({'type' => 'Account', 'action' => 'Preferences', 'function' => ''}); }

sub new {
  ## @overrides
  ## Overrides the constructor to initiate user object by reading the user cookie
  my ($class, $args) = @_;

  my $cookie    = delete $args->{'user_cookie'};
  my $self      = $class->__new($args);

  if ($self->users_available && $cookie) { # always check users_available
    try {
      $self->user = EnsEMBL::Web::User->new($self, $cookie) if $cookie;
    } catch {
      $self->users_available(0);
    };
  }

  return $self;
}

sub url {
  ## @overrides
  ## Clears the core params in case url type is Account
  ## Accepts the following extra keys as arguments
  ##  - csrf_safe : Required with value 1, if the url to be construted has to be safe from 'Cross site request forgery'
  ##  - user      : Required for CSRF safe urls only if the url is to be used by a user different to the logged in user (provide value undef if user yet to be created)
  my $self      = shift;
  my $extra     = $_[0] && !ref $_[0] ? shift : undef;
  my $params    = shift || {};
  my $base_url  = '';

  if (!$params->{'type'} && $self->type eq 'Account' || $params->{'type'} eq 'Account') {
    $params->{'__clear'} = 1;
    $params->{'species'} = 'Multi' if !$params->{'species'} || $params->{'species'} eq 'common';
  }

  if (delete $params->{'csrf_safe'}) {
    my $user = exists $params->{'user'} ? $params->{'user'} : $self->user;
    $params->{$self->CSRF_SAFE_PARAM} = $user ? $user->rose_object->salt : EnsEMBL::Web::User->default_salt;
  }

  # https url
  # $params->{'action'} eq $_ and ($base_url = $self->species_defs->ENSEMBL_LOGIN_URL) =~ s/\/$// and last for EnsEMBL::Web::Configuration::Account->SECURE_PAGES;

  my $url = $self->__url($extra || (), $params, @_);

  return $base_url ? "$base_url$url" : $url;
}

sub get_favourite_species {
  my $self        = shift;
  my $user        = $self->user;
  my @favourites  = $user ? @{$user->favourite_species} : ();

  return @favourites ? \@favourites : $self->__get_favourite_species;
}

sub users_available {
  ## Gets/Sets the flag to check whether users db is connected or not
  ## @param Flag value if setting
  ## @return 0 or 1 accordingly
  my $self = shift;
  
  $self->{'_users_available'} = shift if @_;

  unless (exists $self->{'_users_available'}) {
    $self->{'_users_available'} = 1;
    try {
      ORM::EnsEMBL::DB::Accounts::Manager::User->object_class->init_db->connect;
    } catch {
      $self->{'_users_available'} = 0;
    }
  }

  return $self->{'_users_available'};
}

1;
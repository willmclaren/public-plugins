use strict;

package EnsEMBL::Mirror::SiteDefs;

sub update_conf {
  $SiteDefs::ENSEMBL_PORT                   = 9099;
  $SiteDefs::ENSEMBL_PROXY_PORT             = undef; 
  $SiteDefs::ENSEMBL_SERVERNAME             = undef;
  $SiteDefs::ENSEMBL_STATIC_SERVER          = '';
  $SiteDefs::ENSEMBL_MIRRORS                = undef;

  $SiteDefs::APACHE_DIR                     = '/localsw';
  $SiteDefs::SAMTOOLS_DIR                   = '/localsw/bin/samtools-0.1.18';
  $SiteDefs::BIOPERL_DIR                    = $ENV{HOME}.'/Perl/bioperl-live/';
  $SiteDefs::MINI_BIOPERL_161_DIR           = '/localsw/cvs/mini-bioperl-161/';
  $SiteDefs::ENSEMBL_PRIVATE_AUTH           = '/localsw/etc/privateauth';
  $SiteDefs::DATAFILE_BASE_PATH             = '/nfs/ensnfs-webdev/staging/';

  $SiteDefs::ENSEMBL_API_VERBOSITY          = 'WARNING'; ## Shut up the API a bit!
  $SiteDefs::ENSEMBL_DEBUG_FLAGS           |= $SiteDefs::ENSEMBL_DEBUG_MAGIC_MESSAGES;
  $SiteDefs::ENSEMBL_DEBUG_FLAGS           |= $SiteDefs::ENSEMBL_DEBUG_VERBOSE_STARTUP;
  $SiteDefs::ENSEMBL_DEBUG_FLAGS           |= $SiteDefs::ENSEMBL_DEBUG_EXTERNAL_COMMANDS;

  $SiteDefs::ENSEMBL_MAIL_ERRORS            = 0;

  $SiteDefs::ENSEMBL_USERDB_NAME            = 'ensembl_accounts';
  $SiteDefs::ENSEMBL_USERDB_USER            = 'ensadmin';
  $SiteDefs::ENSEMBL_USERDB_HOST            = 'ensdbweb-1-vip.internal.sanger.ac.uk';
  $SiteDefs::ENSEMBL_USERDB_PORT            =  5305;
  $SiteDefs::ENSEMBL_USERDB_PASS            = 'ensembl';
  $SiteDefs::ENSEMBL_LONGPROCESS_MINTIME    = 10;
  $SiteDefs::ENSEMBL_HELPDESK_EMAIL         = 'helpdesk@ensembl.org';
  $SiteDefs::ENSEMBL_NOREPLY_EMAIL          = 'no-reply@ensembl.org';
  $SiteDefs::TIDY_USERDB_CONNECTIONS       = 1;
  $SiteDefs::ENSEMBL_VERSION                = 89;

  $SiteDefs::ENSEMBL_USERDATA_DIR           = '/nfs/ensembl_tmp/users/wm2/';
  #$SiteDefs::ENSEMBL_TMP_DIR                = './tmp';
  #$SiteDefs::ENSEMBL_LOGDIR                 = './logs';


  $SiteDefs::SOAP_PROXY                     = 'http://wwwcache.sanger.ac.uk:3128';
  $SiteDefs::SAMTOOLS_HTTP_PROXY            = 'http://wwwcache.sanger.ac.uk:3128';

  $SiteDefs::ENSEMBL_MART_ENABLED           = -1; ## This makes it think is enabled - but isn't on this IP!

  $SiteDefs::LUCENE_ENDPOINT                = "http://search.sanger.ac.uk/sanger-web/ws/searchService";
  $SiteDefs::LUCENE_EXT_ENDPOINT            = "http://search.sanger.ac.uk/sanger-web/ws/searchExtService";

  $SiteDefs::SUBSCRIPTION_EMAIL_LISTS       = [
    'announce-join@ensembl.org'               => q(Announcements - low-traffic list for release announcements and major service updates),
    'dev-join@ensembl.org'                    => q(Developers' list - discussion list for users of our API and webcode)
  ];
  
  # stuff from tools_hive
  $SiteDefs::ENSEMBL_VEP_ENABLED            = 1;
  $SiteDefs::ENSEMBL_VEP_CACHE_DIR          = "/nfs/ensembl/wm2/VEP/cache";
  $SiteDefs::ENSEMBL_VEP_SCRIPT_DEFAULT_OPTIONS = {                                                 # Default options for command line vep script (keys with value undef get ignored)
    'host'        => 'ens-livemirror',                                                               # Database host (defaults to ensembldb.ensembl.org)
    'user'        => 'ensro',                                                                     # Defaults to 'anonymous'
    'password'    => undef,                                                                       # Not used by default
    'port'        => 3306,                                                                        # Defaults to 5306
    'fork'        => 4,                                                                           # Enable forking, using 4 forks
    'db_version'  => 87,
  };
  
  # stuff from tools
  $SiteDefs::ENSEMBL_VEP_FILTER_SCRIPT_OPTIONS = {
    '-host'         => 'ens-livemirror',
    '-user'         => 'ensro',
    '-port'         => 3306,
    '-pass'         => undef
  };

  $SiteDefs::ENSEMBL_VEP_PLUGIN_DATA_DIR = '/nfs/ensembl/wm2/VEP/cache/plugin_data';
  $SiteDefs::ENSEMBL_VEP_PLUGIN_DIR = '/nfs/ensembl/wm2/VEP/cache/Plugins';
  $SiteDefs::ENSEMBL_VEP_PLUGIN_BASE_CONFIG = $SiteDefs::ENSEMBL_VEP_PLUGIN_DIR.'/plugin_config.txt';

#  $SiteDefs::ENSEMBL_REST_URL = 'grch37.rest.ensembl.org';
}

1;

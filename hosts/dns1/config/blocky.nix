let
  domain-whitelist = builtins.toFile "domain-whitelist" ''
    *.microsoftonline.us
    auth.split.io
    sdk.split.io
    checkout.shopify.com
  '';
in
{
  ports = {
    dns = "0.0.0.0:53";
    http = 4000;
  };

 bootstrapDns = [
    {
      upstream = "tcp-tls:1.1.1.1:853";
    }
  ];

  upstreams.groups.default = [
    # UDM-SE
    "tcp+udp:10.1.1.1:53"
  ];

  conditional = {
    fallbackUpstream = false;
    mapping = {
      "1.10.in-addr.arpa" = "10.1.1.1:53";
      "greyrock.casa" = "127.0.0.1:5391";
      "greyrock.io" = "10.1.1.1:53";
      "internal" = "10.1.1.1:53";
    };
  };

  # configuration of client name resolution
  clientLookup.upstream = "10.1.1.1";

  ecs = {
    useAsClient = true;
    forward = true;
  };

  prometheus = {
    enable = true;
    path = "/metrics";
  };

  blocking = {
    blockType = "nxDomain";

    loading = {
      downloads.timeout = "4m";
      maxErrorsPerSource = -1;
    };

    blackLists = {
      ads = [ # Ref: https://firebog.net
        "https://adaway.org/hosts.txt"
        "https://v.firebog.net/hosts/AdguardDNS.txt"
        "https://v.firebog.net/hosts/Admiral.txt"
        "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
        "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
        "https://v.firebog.net/hosts/Easylist.txt"
        "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
        "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
      ];
      malicious = [ # Ref: https://firebog.net
        "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
        "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
        "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
        "https://v.firebog.net/hosts/Prigent-Crypto.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
        "https://bitbucket.org/ethanr/dns-blacklists/raw/master/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
        "https://phishing.army/download/phishing_army_blocklist_extended.txt"
        "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
        "https://v.firebog.net/hosts/RPiList-Malware.txt"
        "https://v.firebog.net/hosts/RPiList-Phishing.txt"
        "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
        "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
        "https://urlhaus.abuse.ch/downloads/hostfile/"
      ];
      native = [ # Ref: https://github.com/hagezi/dns-blocklists
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.amazon.txt"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.apple.txt"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.huawei.txt"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.lgwebos.txt"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.tiktok.extended.txt"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.winoffice.txt"
      ];
      other = [ # Ref: https://firebog.net
        "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
      ];
      suspicious = [ # Ref: https://firebog.net
        "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
        "https://v.firebog.net/hosts/static/w3kbl.txt"
      ];
      tracking = [ # Ref: https://firebog.net
        "https://v.firebog.net/hosts/Easyprivacy.txt"
        "https://v.firebog.net/hosts/Prigent-Ads.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
        "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
        "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
      ];
    };

    whiteLists = {
      ads = [
        "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
        "file://${domain-whitelist}"
      ];
      malicious = [
        "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
        "file://${domain-whitelist}"
      ];
      native = [
        "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
        "file://${domain-whitelist}"
      ];
      other = [
        "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
        "file://${domain-whitelist}"
      ];
      suspicious = [
        "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
        "file://${domain-whitelist}"
      ];
      tracking = [
        "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
        "file://${domain-whitelist}"
      ];
    };

    clientGroupsBlock = {
      default = [
        "ads"
        "malicious"
        "native"
        "other"
        "suspicious"
        "tracking"
      ];
    };
  };

  caching = {
    cacheTimeNegative = -1;
    minTime = "10m";
    maxTime = "30m";
    prefetching = true;
    prefetchExpires = "2h";
    prefetchThreshold = 3;
  };

  log = {
    level = "info";
    format = "text";
  };

  redis = {
    address = "10.1.1.158:6379";
    database = 10;
    required = false;
    connectionAttempts = 10;
    connectionCooldown = "3s";
  };
}

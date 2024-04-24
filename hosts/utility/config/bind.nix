{
  config,
  ...
}:
''
include "${config.sops.secrets."networking/bind/rndc-key".path}";
include "${config.sops.secrets."networking/bind/externaldns-key".path}";
controls {
  inet 127.0.0.1 allow {localhost;} keys {"rndc-key";};
};

# Only define known networks as trusted
acl trusted {
  10.1.0.0/24;    # LAN
  10.1.1.0/24;    # SERVERS
  10.1.2.0/24;    # TRUSTED
  10.1.3.0/24;    # WIRELESS
  10.1.4.0/23;    # IOT
  10.1.6.0/24;    # VIDEO
  10.1.7.0/24;    # NTP
  10.1.8.0/24;    # VOICE
  192.168.2.0/24; # GUEST
  10.0.11.0/24;   # WIREGUARD
};
acl badnetworks {  };

options {
  listen-on port 5354 { any; };
  directory "${config.services.bind.directory}";
  pid-file "${config.services.bind.directory}/named.pid";

  allow-recursion { trusted; };
  allow-transfer { none; };
  allow-update { none; };
  blackhole { badnetworks; };
  dnssec-validation auto;
};

logging {
  channel stdout {
    stderr;
    severity info;
    print-category yes;
    print-severity yes;
    print-time yes;
  };
  category security { stdout; };
  category dnssec   { stdout; };
  category default  { stdout; };
};

zone "greyrock.casa." {
  type master;
  file "${config.sops.secrets."networking/bind/zones/greyrock.casa".path}";
  allow-transfer {
    key "externaldns";
  };
  update-policy {
    grant externaldns zonesub ANY;
  };
};
''

{
  config,
  ...
}:
''
include "${config.sops.secrets."networking/bind/rndc-key".path}";
include "${config.sops.secrets."networking/bind/externaldns-key".path}";
include "${config.sops.secrets."networking/bind/dns1-dns2-key".path}";
controls {
  inet 127.0.0.1 allow {localhost;} keys {"rndc-key";};
};

# Only define known networks as trusted
acl trusted {
  10.1.0.0/24;    # LAN
  10.1.1.0/24;    # Servers
  10.1.2.0/24;    # Trusted
  10.1.3.0/24;    # Wireless
  10.1.4.0/23;    # IoT
  10.1.6.0/24;    # Video
  10.1.7.0/24;    # NTP
  10.1.8.0/24;    # Voice
  192.168.2.0/24; # Guest
  10.0.11.0/24;   # Wireguard
  10.88.0.0/24;   # Local Podman
};
acl badnetworks {  };

options {
  listen-on port 5391 { any; };
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

server 10.1.1.12 {
  keys { dns1-dns2; };
};

zone "greyrock.casa." {
  type master;
  file "${config.sops.secrets."networking/bind/zones/greyrock.casa".path}";
  journal "${config.services.bind.directory}/db.greyrock.casa.jnl";
  allow-transfer {
    key "externaldns";
    key "dns1-dns2";
  };
  also-notify { 10.1.1.12 port 5391; };
  update-policy {
    grant externaldns zonesub ANY;
  };
};
''

{
  vm-1 = {
    system = "x86_64-linux";
    address = "192.168.1.60";
    capacity = "20G";
    zone = "dc1";
    sshUser = "root";

    roles = [ "garage" "logging"];
  };
  vm-2 = {
    system = "x86_64-linux";
    address = "192.168.1.61";
    capacity = "20G";
    zone = "dc2";
    sshUser = "root";

    roles = [ "garage" ];
  };
  vm-3 = {
    system = "x86_64-linux";
    address = "192.168.1.62";
    capacity = "20G";
    zone = "dc3";
    sshUser = "root";

    roles = [ "garage" ];
  };
  vm-4 = {
    system = "x86_64-linux";
    address = "192.168.1.63";
    capacity = "20G";
    zone = "dc1";
    sshUser = "root";

    roles = [ "lb" ];
  };
  vm-5 = {
    system = "x86_64-linux";
    address = "192.168.1.64";
    capacity = "20G";
    zone = "dc1";
    sshUser = "root";

    roles = [ "lb" ];
  };

  # later:
  # vps-1 = { system = "x86_64-linux"; address = "1.2.3.4"; sshUser = "root"; };
}


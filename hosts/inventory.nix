{
  vm-1 = {
    system = "x86_64-linux";
    address = "192.168.1.81";
    capacity = "20G";
    zone = "dc1";
    sshUser = "root";

    roles = [ "garage" "logging" "consul"];
  };
  vm-2 = {
    system = "x86_64-linux";
    address = "192.168.1.82";
    capacity = "20G";
    zone = "dc2";
    sshUser = "root";

    roles = [ "garage" ];
  };
  vm-3 = {
    system = "x86_64-linux";
    address = "192.168.1.83";
    capacity = "20G";
    zone = "dc3";
    sshUser = "root";

    roles = [ "garage" ];
  };
  vm-4 = {
    system = "x86_64-linux";
    address = "192.168.1.84";
    capacity = "20G";
    zone = "dc1";
    sshUser = "root";

    roles = [ "lb" ];
  };
  vm-5 = {
    system = "x86_64-linux";
    address = "192.168.1.85";
    capacity = "20G";
    zone = "dc1";
    sshUser = "root";

    roles = [ "lb" ];
  };

  # later:
  # vps-1 = { system = "x86_64-linux"; address = "1.2.3.4"; sshUser = "root"; };
}


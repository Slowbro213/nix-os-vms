{
  services.garageLayout = {
    enable = true;

    # only ONE node should coordinate layout apply
    coordinator = "vm-1";

    nodes = {
      "192.168.1.44:3901" = { zone = "dc1"; capacity = "20G"; };
      "192.168.1.45:3901" = { zone = "dc2"; capacity = "20G"; };
      "192.168.1.46:3901" = { zone = "dc3"; capacity = "20G"; };
    };
  };
}


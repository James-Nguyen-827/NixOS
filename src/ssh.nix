{
  users.users.root.openssh.authorizedKeys.keys = [
    "AAAAC3NzaC1lZDI1NTE5AAAAIJQBmne1OUdPfir8JpqWnt+5ELZh1hfcBsmv+SX5zxLs james@JamesPC"
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
}

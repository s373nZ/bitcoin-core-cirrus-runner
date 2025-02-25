{ pkgs, lib, ... }:

{
  name = "cirrus-task";

  nodes.machine =
    { config, lib, ... }:
    {
      imports = [ ../module.nix ];
      virtualisation.cores = 2;
      virtualisation.memorySize = 12 * 1024;

      users.users.alice = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        initialPassword = "test";
      };

      # DANGER: in a production setup, this should be a secret and not hardcoded
      # in a world (and VM!) readable nix store, or require --impure mode
      environment.etc."cirrus/worker.yml" = {
        #text = "token: " + builtins.getEnv "CIRRUS_WORKER_TOKEN";
        text = "token: 35hpc6fo67bgsqo4jol2lev8ffm6eqcjt5ue9723red6j4k5k0istpv57s02gabddoe1klqcovkh53a2lq9qcd3vcq4iolh2frgc9gg";
      };

      services.cirrus-ephemeral-vm-runner = {
        enable = true;
        name = "cirrus-task-test";
        vms = {
          small = {
            count = 1;
            cpu = 2;
            memory = 8;
          };
        };
      };

      boot.kernelModules = [ "br_netfilter" ];
      boot.kernel.sysctl = {
        "net.bridge.bridge-nf-call-iptables" = 1;
        "net.bridge.bridge-nf-call-ip6tables" = 1;
      };
      #networking.firewall.enable = true;
    };

  # tests that the configuration evaluates, the VMs start and are reachable.
  # Does not test that the VMs remain online or do something.
  testScript = ''
    # Don't start grafana, takes too long.
    machine.succeed("systemctl stop grafana.service")

    machine.wait_for_unit("cache.mount")

    # Wait for system boot.
    machine.wait_for_unit("network-online.target")

    machine.wait_for_unit("cirrus-vm0small.service")

    # Look for task run in the logs.
    machine.wait_until_succeeds("journalctl -u cirrus-vm0small --no-pager | grep \"started task [0-9]+\"", timeout=6000)
  '';
}

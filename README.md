# bitcoin-core-cirrus-runner
An experimental NixOS module for running ephemeral, tmpfs-based Bitcoin Core Cirrus CI runners in QEMU VMs using a shared cache


## Running integration tests

```
nix flake check --print-build-logs --max-jobs 1
```
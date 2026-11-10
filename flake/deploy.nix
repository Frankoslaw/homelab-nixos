{ inputs, self, ... }:
{
  flake.deploy.nodes = { };

  perSystem = { system, ... }: {
    checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
  };
}

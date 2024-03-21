{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShell = pkgs.mkShell {
        JSONNET_PATH = "lib";
        KUBECONFIG = "/var/home/kim/Code/home.yaml";
        
        buildInputs = with pkgs; [
          jsonnet
          kubectl
          cilium-cli
          argocd
          k9s
        ];
      };
    }
  );
}

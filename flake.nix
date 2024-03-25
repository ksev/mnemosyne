{
  description = "Flake for managing my k3s cluster";
  
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  
  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in
    {
      devShell = pkgs.mkShell {
        JSONNET_PATH = "lib";
        KUBECONFIG = "/var/home/kim/Code/home.yaml";
        
        buildInputs = with pkgs; [
          jsonnet
          jsonnet-language-server
          _1password
          kubectl
          cilium-cli
          argocd
          k9s
        ];
      };
    }
  );
}

{
    description = "Flake for comfy-ui";

    inputs = {
        # nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable; # -- dont think we need this
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
        let 
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                config.cudaSupport = true;
            };
            torch-index = "https://download.pytorch.org/whl/cu118";
        in {
            devShells = {
                default = (pkgs.buildFHSUserEnv {
                    name = "comfy-ui";
                    targetPkgs = pkgs: [
                        ( pkgs.python310.withPackages (pp: [
                            pp.pip
                            pp.virtualenv
                        ]))
                    ];

                    profile = ''
                        virtualenv .venv
                        source .venv/bin/activate
                        pip install -i ${torch-index} -r torch-requirements.txt
                        pip install -r requirements.txt

                        echo "##-------------------------------##"
                        echo "## PyTorch environment activated ##"
                        echo "##-------------------------------##"
                    '';
                }).env;
            };
        }
    );
}

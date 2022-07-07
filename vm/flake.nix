{
  inputs.dde-nixos.url = "..";

  outputs = inputs@{ self, dde-nixos }: let 
    nixpkgs = dde-nixos.inputs.nixpkgs;
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        dde-nixos.nixosModules."x86_64-linux"

        {
        imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
        environment.enableDebugInfo = true;
        services.xserver = {
          enable = true;
          displayManager = {
            lightdm.enable = true;
            autoLogin = {
              enable = true;
              user = "test";
            };
          };
          desktopManager.plasma5 = {
            enable = true;
          };
          desktopManager.deepin = {
            enable = true;
          };
        };
        time.timeZone = "Asia/Shanghai";
        i18n = {
          defaultLocale = "zh_CN.UTF-8";
          supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
          inputMethod.enabled = "fcitx";
        };
        users.users.test = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" "networkmanager" ];
          password = "test";
        };
        virtualisation = {
          qemu.options = [ "-device intel-hda -device hda-duplex" ];
          cores = 6;
          memorySize = 8192;
          diskSize = 16384;
          resolution = { x = 1024; y = 768; };
        };
        system.stateVersion = "22.11";
      }];
    };
    packages.x86_64-linux.default = self.nixosConfigurations.vm.config.system.build.vm;
    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.packages.x86_64-linux.default}/bin/run-nixos-vm";
    };
  };
}


{
  description = "qFioofa Herdr config — Home Manager module";

  outputs = { self }: {
    homeManagerModules.default = { ... }: {
      xdg.configFile."herdr/config.toml".source = ./src/config.toml;
    };

    homeManagerModules.qfioofa-herdr = self.homeManagerModules.default;
  };
}

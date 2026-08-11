final: prev: {
  deno = prev.deno.overrideAttrs (old: {
    env =
      builtins.removeAttrs
      (old.env or {})
      ["LIBSQLITE3_SYS_USE_PKG_CONFIG"];

    buildInputs = prev.lib.remove prev.sqlite (old.buildInputs or []);
  });
}

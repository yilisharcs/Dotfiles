let
  inherit
    (builtins)
    attrNames
    attrValues
    concatMap
    filter
    listToAttrs
    match
    readDir
    readFileType
    ;

  optional = condition: consequence:
    if condition
    then [consequence]
    else [];

  listFilesRecursive = base: directory:
    if readFileType directory != "directory"
    then [base]
    else let
      entries = readDir directory;
    in
      concatMap (
        name:
          if entries.${name} == "directory"
          then listFilesRecursive "${base}/${name}" /${directory}/${name}
          else if entries.${name} == "regular"
          then ["${base}/${name}"]
          else []
      ) (attrNames entries);

  isAge = name: match ".*\\.age$" name != null;

  keys = import ./lib/keys.nix;

  hostSecrets =
    attrNames (readDir ./hosts)
    |> concatMap (
      host:
        listFilesRecursive "hosts/${host}" ./hosts/${host}
        |> filter isAge
        |> map (path: {
          name = path;
          value.publicKeys = optional (keys.hosts ? ${host}) keys.hosts.${host};
        })
    );

  moduleSecrets =
    listFilesRecursive "modules" ./modules
    |> filter isAge
    |> map (path: {
      name = path;
      value.publicKeys = attrValues keys.hosts;
    });
in
  listToAttrs (hostSecrets ++ moduleSecrets)
  // {
    # agenix requires secrets.nix entries before files exist.
    # init.age is a catch-all for creating new secrets. run
    # `agenix -e init.age`, and `mv init.age <path` when done.
    # after creation, move to final path.
    "init.age".publicKeys = attrValues keys.hosts;
  }

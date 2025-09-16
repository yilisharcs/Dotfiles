# Project tasks

## init

### meson (name)

> Create a project with Meson and Ninja

Missing flags: --deps

**OPTIONS**
* language
  * flags: -l --language
  * type: string
  * desc: What language will you use in the project?

* lib
  * flags: -t --type
  * desc: Is this a library project?

* deps
  * flags: -d --deps
  * type: string
  * desc: Comma-separated list of dependencies

```nu
# 
# Setup the repo
# 
let root = ([$env.HOME Projects/github.com/yilisharcs] | path join)
let repo = ([$root $env.name] | path join)
trash $repo            # For testing
mkdir $repo; cd $repo

# 
# Arguments for Meson
# 
$env.CC_LD = "mold"

mut cmd = [
    "meson"
    "init"
    "--build"
    "--name"
    $env.name
]

if ($env.language? | is-not-empty) {
    $cmd = ($cmd | append ["--language" $env.language])
}

if ($env.lib? | is-not-empty) {
    $cmd = ($cmd | append ["--type" "library"])
}

if ($env.deps? | is-not-empty) {
    $cmd = ($cmd | append ["--deps" $env.deps])
}

# 
# Pass command string to nushell
# 
$cmd
| str join " "
| nu -c $in

jj git init --colocate
```

# HPI SWA Repo Generator

Generates repositories for the SWA lecture at HPI.

It takes as input
- template repository
- a file from Moodle containing group info
- a directory from Moodle containing GitHub username info
 (the .zip provided by Moodle when downloading all submissions)
- a GitHub token with access to the `repo` and `admin:org` scopes

From these inputs, it
- copies the template repository for each group
- updates references to the group number (`SWAGroup01 -> SWAGroup42`)
- creates a GitHub repository for each group
- pushes the updated copies to the respective repositories
- creates a GitHub team for each repository
- invites the respective group members to the teams
- grants the group teams push rights to the respective repositories
- grants the GitHub team for tutors maintain rights to all repositories

## Dependencies
- [`bash`](https://www.gnu.org/software/bash/)
- [`curl`](https://curl.se/) (for GitHub API)
- [`git`](https://git-scm.com/)
- [`grep`](https://www.gnu.org/software/grep/)
- [`jq`](https://github.com/jqlang/jq) (working with JSON)
- [`lynx`](https://lynx.invisible-island.net/) (extracting data from HTML)
- [`sed`](https://www.gnu.org/software/sed/)
- [GNU findutils (`find`, `xargs`)](https://www.gnu.org/software/findutils/)
- [GNU coreutils (`date`, `mktemp`, `mv`, `seq`)](https://www.gnu.org/software/coreutils/)

## Running

Just execute the script without arguments, it will ask for what it needs.

Some prompts will have default values:

> *Prompt* \[*default*]:

The *default* can be accepted by pressing enter.

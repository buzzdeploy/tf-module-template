# Release Please

A reuseable workflow used to aid the release process and documenting the changes with less effort from the maintainer and or team. 

## Init

Release Please requires a repository to be initialized first. Todo so, must one have NPM installed and one must run: `npm -i release-please`. The documentation wants the `-g` switch at the end for a global install (required to use from a common system path).

Once the installation is completed, initialize repository with the following: 
```bash
release-please bootstrap \
  --token=$GITHUB_TOKEN \
  --repo-url=<owner>/<repo> \
  --release-type=simple
```

The GitHub token being your personal access token. You will know it was successful when GitHub has a PR ready for you with 2 files added. They are: 
* `.release-please-manifeset.json`
* `release-please-config.json`

## Resourcs
* [Release Please GitHub](https://github.com/google-github-actions/release-please)
* [Init Release Please Docs](https://github.com/googleapis/release-please/blob/main/docs/cli.md)


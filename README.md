# gitlab-runner on balenaOS devices

[GitLab runners][runners] are worker nodes to run your tests in a GitLab CI/CD
environment. This project aims to help you deploy these runners on physical
hardware on balenaOS devices.

Features:

* a `docker` executor gitlab runner
* automatic first runner provisioning to a gitlab instance, only need to
  provide a token
* can add multiple runners to a single device manually
* automatic docker image/container garbage collection using
  [docker-gc][docker-gc] by Spotify.

Discuss this project in the [forums][forums]!

## Getting Started

If using balenaCloud, follow the [getting started guide][getting started] for
your desired device type, to see how to register (if you haven't yet), and how
to provision a device onto balenaCloud. Afterwards deploy this project either as
`git push balena master` or using the [CLI][cli] with `balena push <projectname>`.

If using [openbalena][openbalena], follow the guides there to provision a device,
and run `balena push <projectname>` as appropriate.

## Settings

There are a number of environment variables you can customise your deployment
with. These help setting up your first runner automatically:

* `GITLAB_TOKEN`: *required*, the runner registration token, you can get the
  value from the **Settings** > **CI/CD** > **Runners** page for a particular
  project, or from your GitLab instance's administration page.
* `GITLAB_URL`: *optional*, the URL where the runner should connect to. The
  default is value `https://gitlab.com/`. You can see what you need to set for
  a particular project at the **Settings** > **CI/CD** > **Runners** page.
* `GITLAB_DESCRIPTION`: *optional*, the description added to the runner on your
  runner page. If left empty, defaults to the device's short UUID.
* `GITLAB_DEFAULT_IMAGE`:*optional*, the default image to use in jobs, if
  the job doesn't specify the image. If left empty it defaults to
  `balenalib/<devicetype>-debian`, with the device type automatically filled in.
* `TAG_ARCHITECTURE`: *optional*, whether or not create the runner with tag
  showing the architecture (as given by `uname -m`, such as `armv7l`, `x64_64`,
  etc). Left empty defaults to `yes`, and any other value will prevent this tag
  being added.
* `TAG_DEVICE_TYPE`: *optional*,  whether or not create the runner with tag
  showing the balena device type (i.e. `raspberrypi3`, `intel-nuc`, etc). Left
  empty defaults to `yes`, and any other value will prevent this tag being added.
* `TAG_BALENA`: *optional*, whether or not tag the runner with the `balena` tag,
  thus showing clearly what are balena devices among your runners, if there are
  other types as well. If left empty, defaults to `yes`, and any other value will
  prevent this tag being added.
* `GITLAB_TAGS`: *optional*, the list of any other tags to add (comma delimited,
  such as `office,screen`).
* `GITLAB_RUN_UNTAGGED`: *optional*, whether or not run untagged build jobs.
  Left empty defaults to `yes` (do run untagged jobs), any other value make it
  run only tagged jobs (and matching tags). You can also change this on your
  runner configuration page.
* `GITLAB_LOCKED`: *optional*, whether or not the runner is locked to a specific
  project. Left empty defaults to `yes` (locked to a project), any other value
  makes it default unlocked. You can also change this on your runner
  configuration page.

See more information at the [Configuring GitLab Runners docs][config]. The
configuration file is also available to edit.

### Adding extra runners

For subsequent runners you will have to use the terminal to set them up. Connect
to the `runner` service either in the web dashboard, `balena ssh $UUID` (on
balenaCloud) or `balena local ssh $UUID` (on openbalena), and check out
`gitlab-runner register --help` for options.


[cli]: https://github.com/balena-io/balena-cli "balena CLI on GitHub"
[config]: https://docs.gitlab.com/ee/ci/runners/README.html "Configuring GitLab Runners"
[docker-gc]: https://github.com/spotify/docker-gc/ "docker-gc on GitHub"
[forums]: https://forums.balena.io/t/gitlab-runner-on-balena-devices-for-continuous-integration-testing/5090
[getting started]: https://www.balena.io/docs/learn/getting-started/raspberrypi3/go/ "Raspberry Pi 3 - golang getting started"
[openbalena]: https://www.balena.io/open/ "openbalena home page"
[runners]: https://docs.gitlab.com/runner/ "GitLab Runner"

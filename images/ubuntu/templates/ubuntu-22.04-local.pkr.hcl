packer {
}

variable "dockerhub_login" {
  type    = string
  default = "${env("DOCKERHUB_LOGIN")}"
}

variable "dockerhub_password" {
  type    = string
  default = "${env("DOCKERHUB_PASSWORD")}"
}

variable "helper_script_folder" {
  type    = string
  default = "/imagegeneration/helpers"
}

variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}

variable "image_os" {
  type    = string
  default = "ubuntu22"
}

variable "image_version" {
  type    = string
  default = "dev"
}

variable "imagedata_file" {
  type    = string
  default = "/imagegeneration/imagedata.json"
}

variable "installer_script_folder" {
  type    = string
  default = "/imagegeneration/installers"
}

source "null" "build_image" {
  communicator = "none"
}

build {
  sources = ["source.null.build_image"]

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline          = ["mkdir -p ${var.image_folder}", "chmod 777 ${var.image_folder}"]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    script          = "${path.root}/../scripts/build/configure-apt-mock.sh"
  }

  provisioner "shell-local" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = [
      "${path.root}/../scripts/build/install-ms-repos.sh",
      "${path.root}/../scripts/build/configure-apt-sources.sh",
      "${path.root}/../scripts/build/configure-apt.sh"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    script          = "${path.root}/../scripts/build/configure-limits.sh"
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp -r ${path.root}/../scripts/helpers ${var.helper_script_folder}"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp -r ${path.root}/../scripts/build ${var.installer_script_folder}"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp -r ${path.root}/../assets/post-gen ${var.image_folder}",
      "cp -r ${path.root}/../scripts/tests ${var.image_folder}",
      "cp -r ${path.root}/../scripts/docs-gen ${var.image_folder}"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp -r ${path.root}/../../../helpers/software-report-base ${var.image_folder}/docs-gen/"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp ${path.root}/../toolsets/toolset-2204.json ${var.installer_script_folder}/toolset.json"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline          = [
      "mv ${var.image_folder}/docs-gen ${var.image_folder}/SoftwareReport",
      "mv ${var.image_folder}/post-gen ${var.image_folder}/post-generation"
    ]
  }

  provisioner "shell-local" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGEDATA_FILE=${var.imagedata_file}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/configure-image-data.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "IMAGE_OS=${var.image_os}", "HELPER_SCRIPTS=${var.helper_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/configure-environment.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/install-apt-vital.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/install-powershell.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "{{ .Vars }}", "pwsh", "-f", "{{ .Script }}"]
    scripts          = ["${path.root}/../scripts/build/Install-PowerShellModules.ps1", "${path.root}/../scripts/build/Install-PowerShellAzModules.ps1"]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "DEBIAN_FRONTEND=noninteractive"]
    # execute_command  = ["sudo", "/bin/sh", "-c", "{{.Vars}}", "{{.Script}}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = [
      "${path.root}/../scripts/build/install-actions-cache.sh",
      "${path.root}/../scripts/build/install-runner-package.sh",
      "${path.root}/../scripts/build/install-apt-common.sh",
      "${path.root}/../scripts/build/install-azcopy.sh",
      "${path.root}/../scripts/build/install-azure-cli.sh",
      "${path.root}/../scripts/build/install-azure-devops-cli.sh",
      "${path.root}/../scripts/build/install-bicep.sh",
      "${path.root}/../scripts/build/install-aliyun-cli.sh",
      "${path.root}/../scripts/build/install-apache.sh",
      "${path.root}/../scripts/build/install-aws-tools.sh",
      "${path.root}/../scripts/build/install-clang.sh",
      "${path.root}/../scripts/build/install-swift.sh",
      "${path.root}/../scripts/build/install-cmake.sh",
      "${path.root}/../scripts/build/install-codeql-bundle.sh",
      "${path.root}/../scripts/build/install-container-tools.sh",
      "${path.root}/../scripts/build/install-dotnetcore-sdk.sh",
      "${path.root}/../scripts/build/install-firefox.sh",
      "${path.root}/../scripts/build/install-microsoft-edge.sh",
      "${path.root}/../scripts/build/install-gcc-compilers.sh",
      "${path.root}/../scripts/build/install-gfortran.sh",
      "${path.root}/../scripts/build/install-git.sh",
      "${path.root}/../scripts/build/install-git-lfs.sh",
      "${path.root}/../scripts/build/install-github-cli.sh",
      "${path.root}/../scripts/build/install-google-chrome.sh",
      "${path.root}/../scripts/build/install-google-cloud-cli.sh",
      "${path.root}/../scripts/build/install-haskell.sh",
      "${path.root}/../scripts/build/install-heroku.sh",
      "${path.root}/../scripts/build/install-java-tools.sh",
      "${path.root}/../scripts/build/install-kubernetes-tools.sh",
      "${path.root}/../scripts/build/install-oc-cli.sh",
      "${path.root}/../scripts/build/install-leiningen.sh",
      "${path.root}/../scripts/build/install-miniconda.sh",
      "${path.root}/../scripts/build/install-mono.sh",
      "${path.root}/../scripts/build/install-kotlin.sh",
      "${path.root}/../scripts/build/install-mysql.sh",
      "${path.root}/../scripts/build/install-mssql-tools.sh",
      "${path.root}/../scripts/build/install-sqlpackage.sh",
      "${path.root}/../scripts/build/install-nginx.sh",
      "${path.root}/../scripts/build/install-nvm.sh",
      "${path.root}/../scripts/build/install-nodejs.sh",
      "${path.root}/../scripts/build/install-bazel.sh",
      "${path.root}/../scripts/build/install-oras-cli.sh",
      "${path.root}/../scripts/build/install-php.sh",
      "${path.root}/../scripts/build/install-postgresql.sh",
      "${path.root}/../scripts/build/install-pulumi.sh",
      "${path.root}/../scripts/build/install-ruby.sh",
      "${path.root}/../scripts/build/install-rlang.sh",
      "${path.root}/../scripts/build/install-rust.sh",
      "${path.root}/../scripts/build/install-julia.sh",
      "${path.root}/../scripts/build/install-sbt.sh",
      "${path.root}/../scripts/build/install-selenium.sh",
      "${path.root}/../scripts/build/install-terraform.sh",
      "${path.root}/../scripts/build/install-packer.sh",
      "${path.root}/../scripts/build/install-vcpkg.sh",
      "${path.root}/../scripts/build/configure-dpkg.sh",
      "${path.root}/../scripts/build/install-yq.sh",
      "${path.root}/../scripts/build/install-android-sdk.sh",
      "${path.root}/../scripts/build/install-pypy.sh",
      "${path.root}/../scripts/build/install-python.sh",
      "${path.root}/../scripts/build/install-zstd.sh"
    ]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "DOCKERHUB_LOGIN=${var.dockerhub_login}", "DOCKERHUB_PASSWORD=${var.dockerhub_password}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/install-docker-compose.sh", "${path.root}/../scripts/build/install-docker.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "{{.Vars}}", "pwsh", "-f", "{{.Script}}"]
    scripts          = ["${path.root}/../scripts/build/Install-Toolset.ps1", "${path.root}/../scripts/build/Configure-Toolset.ps1"]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/install-pipx-packages.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}", "DEBIAN_FRONTEND=noninteractive", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/install-homebrew.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPTS=${var.helper_script_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/configure-snap.sh"]
  }

  #provisioner "shell-local" {
  #  execute_command   = ["sudo", "/bin/sh", "-c", "{{.Vars}}", "{{.Script}}"]
  #  expect_disconnect = true
  #  inline            = ["echo 'Reboot VM'", "sudo reboot"]
  #}

  provisioner "shell-local" {
    execute_command     = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    pause_before        = "1m0s"
    scripts             = ["${path.root}/../scripts/build/cleanup.sh"]
  }

  provisioner "shell-local" {
    environment_vars = ["IMAGE_VERSION=${var.image_version}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}"]
    inline           = ["pwsh -File ${var.image_folder}/SoftwareReport/Generate-SoftwareReport.ps1 -OutputDirectory ${var.image_folder}", "pwsh -File ${var.image_folder}/tests/RunAll-Tests.ps1 -OutputDirectory ${var.image_folder}"]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp ${var.image_folder}/software-report.md ${path.root}/../Ubuntu2204-Readme.md"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp ${var.image_folder}/software-report.json ${path.root}/../software-report.json"
    ]
  }

  provisioner "shell-local" {
    environment_vars = ["HELPER_SCRIPT_FOLDER=${var.helper_script_folder}", "INSTALLER_SCRIPT_FOLDER=${var.installer_script_folder}", "IMAGE_FOLDER=${var.image_folder}"]
    execute_command  = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    scripts          = ["${path.root}/../scripts/build/configure-system.sh"]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline = [
      "cp ${path.root}/../assets/ubuntu2204.conf /tmp/"
    ]
  }

  provisioner "shell-local" {
    execute_command = ["sudo", "/bin/sh", "-c", "chmod +x {{ .Script }} && sudo bash -c '{{ .Vars }} {{ .Script }}'"]
    inline          = ["mkdir -p /etc/vsts", "cp /tmp/ubuntu2204.conf /etc/vsts/machine_instance.conf"]
  }

}

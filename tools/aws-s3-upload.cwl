#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: CommandLineTool
$namespaces:
  arv: http://arvados.org/cwl#
  cwltool: http://commonwl.org/cwltool#

requirements:
  DockerRequirement:
    dockerFile:
      $include: awscli.cwltool.dockerfile
    dockerImageId: arvados/awscli:0.5
  InitialWorkDirRequirement:
    listing:
    - entryname: .aws/credentials
      entry: |
        [default]
        aws_access_key_id=$(inputs.aws_access_key_id)
        aws_secret_access_key=$(inputs.aws_secret_access_key)
    - entryname: upload.sh
      entry: |
        ${
        // cwltool expression scanner has trouble with unbalanced quotes, the workaround
        // is adding the comment on the next line
        var rx = /['\\]/g; // '
        var quote = function(s) { return "'"+s.replace(rx, "")+"'"; }

        // Determine endpoint
        var endpoint = "";
        if (inputs.endpoint) {
          endpoint = "--endpoint "+quote(inputs.endpoint);
        }
        // Create and return command
        var commands = inputs.files.map(function(file) {
          // Set s3target based on whether to preserve structure
          var s3target = ""
          if (inputs.preserve_structure === false) {
            s3target = quote(inputs.s3target + file.basename);
          } else {
            var location = file.location
            var file_path = location.replace(/^keep:[^\/]+\//, "")
            s3target = quote(inputs.s3target + file_path);
          }

          return "aws s3 cp "+endpoint+" --no-progress "+quote(file.path)+" "+quote(s3target);
        });
        commands.unshift("set -e");
        commands.push("");
        return commands.join("\n");
        }
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  ResourceRequirement:
    ramMin: $(inputs.ramMin)
  WorkReuse:
    enableReuse: false

inputs:
  aws_access_key_id: string
  aws_secret_access_key: string
  endpoint: string?
  files: File[]
  preserve_paths:
    type: boolean
    default: false
  ramMin:
    type: int
    default: 1000
  s3target: string

outputs: []
arguments:
- /bin/sh
- upload.sh

hints:
  cwltool:Secrets:
    secrets:
    - aws_access_key_id
    - aws_secret_access_key

class: CommandLineTool
cwlVersion: v1.2

$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"

inputs:
  s3urls: string[]
  aws_access_key_id: string
  aws_secret_access_key: string
  endpoint: string?
  ramMin:
    type: int
    default: 1000

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerFile: {$include: awscli.cwltool.dockerfile}
    dockerImageId: arvados/awscli:0.5
  NetworkAccess:
    networkAccess: true
  ResourceRequirement:
    ramMin: $(inputs.ramMin)
  InitialWorkDirRequirement:
    listing:
      - entryname: .aws/credentials
        entry: |
          [default]
          aws_access_key_id=$(inputs.aws_access_key_id)
          aws_secret_access_key=$(inputs.aws_secret_access_key)
      - entryname: download.sh
        entry: |
          ${
          var quote = function(s) { return "'"+s.replaceAll("'", "").replaceAll("\\", "")+"'"; }
          var endpoint = "";
          if (inputs.endpoint) {
            endpoint = "--endpoint "+quote(inputs.endpoint);
          }
          var commands = inputs.s3urls.map(function(url) {
            return "aws s3 cp "+endpoint+" --no-progress "+quote(url)+" "+quote(url.split('/').pop());
          });
          commands.unshift("set -e");
          commands.push("");
          return commands.join("\n");
          }

hints:
  cwltool:Secrets:
    secrets: [aws_access_key_id, aws_secret_access_key]
  arv:RuntimeConstraints:
    outputDirType: keep_output_dir

arguments: ["/bin/sh", "download.sh"]

outputs:
  files:
    type: File[]
    outputBinding:
      glob: $(inputs.s3urls.map(function(url) { return url.split('/').pop(); }))

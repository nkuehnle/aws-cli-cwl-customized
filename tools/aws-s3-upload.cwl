class: CommandLineTool
cwlVersion: v1.2

$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"

inputs:
  files: File[]
  s3target: string
  aws_access_key_id: string
  aws_secret_access_key: string
  endpoint: string?

requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerFile: {$include: awscli.cwltool.dockerfile}
    dockerImageId: arvados/awscli:0.5
  NetworkAccess:
    networkAccess: true
  ResourceRequirement:
    ramMin: 3000
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
          var endpoint = "";
          if (inputs.endpoint) {
            endpoint = "--endpoint "+inputs.endpoint+" ";
          }
          var commands = inputs.files.map(function(file) {
            return "aws s3 cp "+endpoint+" --no-progress '"+file.path+"' '"+inputs.s3target+file.basename+"'";
          });
          commands.push("");
          return commands.join("\n");
          }

hints:
  cwltool:Secrets:
    secrets: [aws_access_key_id, aws_secret_access_key]

arguments: ["/bin/sh", "upload.sh"]

outputs: []

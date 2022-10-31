class: CommandLineTool
cwlVersion: v1.2

$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"

inputs:
  file: File
  s3url: string
  aws_access_key_id: string
  aws_secret_access_key: string

requirements:
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  DockerRequirement:
    dockerPull: amazon/aws-cli
  InitialWorkDirRequirement:
    listing:
      - entryname: .aws/credentials
        entry: |
          [default]
          aws_access_key_id=$(inputs.aws_access_key_id)
          aws_secret_access_key=$(inputs.aws_secret_access_key)

hints:
  cwltool:Secrets:
    secrets: [aws_access_key_id, aws_secret_access_key]

arguments: ["s3", "cp", $(inputs.file), $(inputs.s3url)/$(inputs.file.basename)]

outputs: []

class: CommandLineTool
cwlVersion: v1.2

$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"

inputs:
  s3url: string
  aws_access_key_id: string
  aws_secret_access_key: string
  endpoint: string?

requirements:
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
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
  arv:RuntimeConstraints:
    outputDirType: keep_output_dir

arguments: ["aws", "s3", "cp",
  {valueFrom: $(inputs.endpoint), prefix: "--endpoint"},
  $(inputs.s3url), $(inputs.s3url.split('/').pop())]

outputs:
  file:
    type: File
    outputBinding:
      glob: $(inputs.s3url.split('/').pop())

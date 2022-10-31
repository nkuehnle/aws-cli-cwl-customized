class: Workflow
cwlVersion: v1.2

$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  DockerRequirement:
    dockerFile: |
      FROM debian:11-slim
      RUN apt-get update && apt-get install -qy --no-install-recommends awscli python3-pip python3-setuptools build-essential nodejs
      RUN pip3 install wheel && pip3 install cwltool
    dockerImageId: arvados/awscli:0.3
  NetworkAccess:
    networkAccess: true
  arv:RunInSingleContainer: {}

hints:
  cwltool:Secrets:
    secrets: [aws_access_key_id, aws_secret_access_key]

inputs:
  s3url: string[]
  aws_access_key_id: string
  aws_secret_access_key: string
  endpoint: string

steps:
  sc:
    in:
      s3url: s3url
      aws_access_key_id: aws_access_key_id
      aws_secret_access_key: aws_secret_access_key
      endpoint: endpoint
    scatter: s3url
    run: aws-s3-cp.cwl
    out: [file]

outputs:
  files:
    type: File[]
    outputSource: sc/file

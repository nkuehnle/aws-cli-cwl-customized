class: Workflow
cwlVersion: v1.2

#
# Workflow to bulk transfer a list of S3 objects
# This is the main workflow.
#
# See README for details.

$namespaces:
  arv: "http://arvados.org/cwl#"
  cwltool: "http://commonwl.org/cwltool#"

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

hints:
  cwltool:Secrets:
    secrets: [aws_access_key_id, aws_secret_access_key]

inputs:
  files: File[]
  s3target: string
  aws_access_key_id: string
  aws_secret_access_key: string
  parallel_transfers:
    type: int
    default: 1
  endpoint: string

steps:
  split:
    in:
      urls: files
      count: parallel_transfers
    run: tools/batch.cwl
    out: [batches]

  scatter:
    in:
      files: split/batches
      s3target: s3target
      aws_access_key_id: aws_access_key_id
      aws_secret_access_key: aws_secret_access_key
      endpoint: endpoint
    scatter: files
    run: tools/aws-s3-scatter-upload.cwl
    out: []

outputs: []

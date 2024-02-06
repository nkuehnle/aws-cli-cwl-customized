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
  s3urls: string[]
  aws_access_key_id: string
  aws_secret_access_key: string
  parallel_downloads:
    type: int
    default: 1
  endpoint: string

steps:
  split:
    in:
      urls: s3urls
      count: parallel_downloads
    run: tools/batch.cwl
    out: [batches]

  scatter:
    in:
      s3url: split/batches
      aws_access_key_id: aws_access_key_id
      aws_secret_access_key: aws_secret_access_key
      endpoint: endpoint
    scatter: s3url
    run: tools/aws-s3-scatter-download.cwl
    out: [files]

  merge:
    in:
      infiles: scatter/files
    run: tools/merge.cwl
    out: [files]

outputs:
  files:
    type: File[]
    outputSource: [merge/files]
